

# install.packages("devtools")
# install_github("rstudio/ggplot2")


## General purpose libraries
library(zoo)

library(tidyverse)
library(lubridate)
library(scales)
library(purrr)
library(stringr)
library(data.table)


## Spatial libraries
library(sp)
library(adehabitatHR)
library(sf)
library(raster)

## Visualisation / Plotting
library(leaflet)
library(plotly)
library(tmap)

euclid <- function(x1,y1,x2,y2){
  return(sqrt((x1-x2)^2+(y1-y2)^2)) 
}




#############################################################################
## Lesson 1 #################################################################
#############################################################################
# - Set up Rstudio Project
# - Import and clean data
# - Explore Dataset: remove outliers, find sampling interval, make subsets and find overlapping areas of individuals)
# - Make my first simple map


## Read and clean data


# Visualize Points via. lat/long. Note: lat/long are plotted as cartesian coordinates
ggplot(wildschwein, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  coord_fixed(1) +
  theme(legend.position = "none")

wildschwein <- filter(wildschwein,Lat<50)



# turn df into sf-object
wildschwein_sf = st_as_sf(wildschwein, coords = c("Long", "Lat"), crs = 4326, agr = "constant")

# Transform coordinate system
wildschwein_sf <- st_transform(wildschwein_sf, 2056)

wildschwein <- wildschwein_sf %>%
  st_coordinates() %>%
  as_tibble() %>%
  rename(E = X, N = Y) %>%
  bind_cols(wildschwein)



#############################################################################
## Lesson 2 #################################################################
#############################################################################
# - Enrich trajectories (step length, speed, 5min/3hrs)
# - Simple multi-scale analysis (with dplyr summarize for 5min and 3hrs)
# - Moving windows
# - Map back in space
wildschwein <- wildschwein %>%
  group_by(TierID) %>%
  mutate(
    timelag = as.integer(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs"))
  )
    


wildschwein <- wildschwein %>%
  group_by(TierID) %>%
  mutate(
    steplength = euclid(lead(E),lead(N),E,N),
    speed = steplength/timelag,
    speed2 = rollmean(speed,3,NA,align = "left"),
    speed3 = rollmean(speed,5,NA,align = "left"),
    speed4 = rollmean(speed,10,NA,align = "left")
  )


ggplot() +
  geom_line(data = wildschwein[1:50,], aes(DatetimeUTC,speed), colour = "black") +
  geom_line(data = wildschwein[1:50,], aes(DatetimeUTC,speed2), colour = "red") +
  geom_line(data = wildschwein[1:50,], aes(DatetimeUTC,speed3), colour = "green") +
  geom_line(data = wildschwein[1:50,], aes(DatetimeUTC,speed4), colour = "blue")



## How fast is a Cow, or a Wild Boar?
# We want to find out if an animal is moving or resting. The simplest way to do  
# this would be to calculate the distance or traveling speed between two points  
# and define a threshold and based on gps accuracy to decide whether an animal 
# is moving or not. 

# Laube & Purves (2011) define "static" fixes as "those whose average Euclidean
# distance to other fixes inside a temporal window v is less than some
# threshold d".

# Let's create this on our some dummy coordinates and work with them for now.


sample <- wildschwein[0:50,] %>%
  rowid_to_column("rowid") %>%
  mutate(
    Em2 = lag(E,2),
    Nm2 = lag(N,2),
    Em1 = lag(E,1),
    Nm1 = lag(N,1),    
    Ep1 = lead(E,1),
    Np1 = lead(N,1),    
    Ep2 = lead(E,2),
    Np2 = lead(N,2)
  )

n = 10
ggplotly(
ggplot(sample[1:50,],aes(E,N)) + 
  geom_point() + 
  geom_path(alpha = 0.8) +
  geom_segment(data = sample[n:n,],alpha = 0.8,lty = "dotted",colour = "red",aes(x = Em2,y = Nm2,xend = E,yend = N),inherit.aes = FALSE ) +
  geom_segment(data = sample[n:n,],alpha = 0.8,lty = "dotted",colour = "red",aes(x = Em1,y = Nm1,xend = E,yend = N),inherit.aes = FALSE ) +
  geom_segment(data = sample[n:n,],alpha = 0.8,lty = "dotted",colour = "red",aes(x = Ep1,y = Np1,xend = E,yend = N),inherit.aes = FALSE ) +
  geom_segment(data = sample[n:n,],alpha = 0.8,lty = "dotted",colour = "red",aes(x = Ep2,y = Np2,xend = E,yend = N),inherit.aes = FALSE ) 
)




# We'll assume they have a sampling interval of 5 minutes. If we take a temporal
# window of 20 minutes, that would mean we include 5 fixes into the calculation.
# We need to calculate the following Eucledian distances (pos representing a
# X,Y-position):

# 1) pos[n-2] to pos[n]
# 2) pos[n-1] to pos[n]
# 3) pos[n] to pos[n+1]
# 4) pos[n] to pos[n+2]

# We can use the custom function "euclid()" to calculate the distances
# and dplyr functions lead/lag to create the necessary offsets.
before_last_pos <- euclid(lag(X, 2),lag(Y, 2),X,Y)   # 1)
last_pos <- euclid(lag(X, 1),lag(Y, 1),X,Y)   # 2)
next_pos <- euclid(X,Y,lead(X, 1),lead(Y, 1)) # 3)
after_next_pos <- euclid(X,Y,lead(X, 2),lead(Y, 2)) # 4)

# We now want to find out the mean PER ROW. The follwing gives us the overall mean:
mean(c(before_last_pos,last_pos,next_pos,after_next_pos), na.rm = T) 
# To retrive the mean per row, we can do this:
rowMeans <- rowMeans(
  cbind(before_last_pos,last_pos,next_pos,after_next_pos) # binds the vectors as columns as a matrix
)

# We can now combine the above code with a mutate funtion and thus append the rowMean values 
# to our roe deer data:
wildschwein <- wildschwein %>%
  group_by(TierID) %>%
  mutate(
    stepMean = rowMeans(
      cbind(
        euclid(lag(E, 2),lag(N, 2),E,N),
        euclid(lag(E, 1),lag(N, 1),E,N),
        euclid(E,N,lead(E, 1),lead(N, 1)),
        euclid(E,N,lead(E, 2),lead(N, 2))
        )
      )
  )

# This illustrates very nicely what dplyr can do. You can do basically anything with your grouped 
# intput data, as long as the output is a vector dplyr can deal with it. Note, you've yust coded a
# moving window with n = 5 fixes.

wildschwein %>%
  ggplot(aes(stepMean)) +
  geom_histogram(binwidth = 1)+
  lims(x = c(0,100)) +
  geom_vline(xintercept = 10)

wildschwein <- wildschwein %>%
  mutate(
    stop = stepMean < 100
  )

factpal <- colorFactor(hue_pal()(2), wildschwein$stop)

# checking to see if this all makes sense in leaflet: (or better ggplto?)
wildschwein[0:20,] %>%
  filter(!is.na(stop)) %>%
  leaflet() %>%
  addCircles(radius = 1,lng = ~Long, lat = ~Lat, color = ~factpal(stop)) %>%
  addPolylines(opacity = 0.1,lng = ~Long, lat = ~Lat) %>%
  addTiles() %>%
  addLegend(pal = factpal, values = ~stop, title = "Point belongs to stop?")



#############################################################################
## Lesson 3 #################################################################
#############################################################################

# - Matt's students package
# - Compute similarities between trajectories (similarity measure from leiden workshop?!)
# 
# Introduction of Rmarkdown for Project?

library(recurse)


sample <- 


plot(sample$E, sample$N, col = viridis_pal()(nrow(sample)), pch = 20, 
     xlab = "x", ylab = "y", asp = 1)

ggplot(sample, aes(steplength)) +geom_histogram(binwidth = 1) +lims(x = c(0,50))

str(martin)
str(sample)

sample <- wildschwein %>% 
  filter(TierID == "001A") %>%
  select(E,N,DatetimeUTC,TierID) %>%
  as.data.frame()

revis <- getRecursions(sample,50)

revis_stat <- revis$revisitStats

revis_stat2 <- revis_stat %>%
  group_by(coordIdx) %>%
  summarise(
    number_of_visits = max(visitIdx),
    x = unique(x),
    y = unique(y),
    total_time = sum(timeInside),
    max_time = max(timeInside),
    mean_time = mean(timeInside)
  )

ggplotly(
ggplot() +
  geom_point(data = sample,aes(E,N))+
  geom_point(data = filter(revis_stat2,number_of_visits > 10), aes(x,y, size = total_time),colour = "red",alpha = 0.2) +
  scale_size_continuous()
)



#############################################################################
## Lesson 4 #################################################################
#############################################################################
# - Operationalize and find meet patterns 
# - Visualize spatial distribution of meet
# - Define functions

mcp95 <- mcp_sf(wildschwein_sf,TierID, 95)




mcp95 %>%
  filter(ug == "ug1") %>%
  st_bbox()

mcp95 %>%
  filter(ug == "ug1") %>%
  ggplot() +
  geom_sf(aes(fill = id), alpha = 0.3) +
  # geom_sf(data = st_centroid(mcp95), aes(colour = id)) +
  coord_sf(datum = 2056) + 
  theme(
    legend.position = "none",
    panel.grid.major = element_line(colour = "transparent"),
    panel.background = element_rect(fill = "transparent")
    )

pl
# Find spatial overlap
overlap_spatial_mat <- overlap_spatial(mcp95,"id")

# Find temporal overlap
wildschwein_intervals <- wildschwein %>%
  group_by(TierID) %>%
  summarise(
    min = min(DatetimeUTC,na.rm = T),
    max = max(DatetimeUTC,na.rm = T)
  ) %>%
  ungroup() %>%
  mutate(
    interval = interval(min,max)
  )


overlap_temporal_mat <- overlap_temporal(wildschwein_intervals,"interval","TierID")


overlap_spat_temp <- overlap_temporal_mat & overlap_spatial_mat

overlap_spat_temp <- overlap_spat_temp %>%
  as.data.frame() %>%
  rownames_to_column("id1") %>%
  gather(id2,bool,-id1) %>%
  filter(bool == TRUE) %>%
  select(-bool)






temporal_join(wildschwein,TierID,overlap_spat_temp$id1[1],overlap_spat_temp$id2[1],DatetimeUTC,mult = "first",0)



ggplot(temporal_join) +
  geom_point(aes(E2,N2), colour = "blue") +
  geom_point(aes(E1,N1), colour = "red")


leaflet(temporal_join) %>%
  addCircles(lng = ~Long1,lat = ~Lat1) %>%
  addTiles()


#############################################################################
## Lesson 5 #################################################################
#############################################################################
# - enrich trajectories with R (overlay)
# - attach context (land-use, slope) to trajectories, 
# - search for correlations (speed vs. slope, speed vs. landUse). BSc Tomlinson
# - Mapmatching MTB tracks on paths
# - Area centered analysis (MCP, DU, KDE, home range)

