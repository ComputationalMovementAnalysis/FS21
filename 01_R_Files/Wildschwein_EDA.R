

# install.packages("devtools")
devtools::install_git("https://github.engineering.zhaw.ch/PatternsTrendsEnvironmentalData/CMAtools.git")
# install_github("rstudio/ggplot2")


## General purpose libraries
library(CMAtools)
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


euclid <- function(x1,y1,x2,y2){
  return(sqrt((x1-x2)^2+(y1-y2)^2)) 
}

str_remove_trailing <- function(string,trailing_char){
  ifelse(str_sub(string,-1,-1) == trailing_char,str_sub(string,1,-2),string)
}


#############################################################################
## Lesson 1 #################################################################
#############################################################################
# - Set up Rstudio Project
# - Import and clean data
# - Explore Dataset: remove outliers, find sampling interval, make subsets and find overlapping areas of individuals)
# - Make my first simple map


## Read and clean data
wildschwein <- read_delim("20_Rawdata/wildschwein.csv",";",col_types = cols(timelag = col_double()))

wildschwein <- rowid_to_column(wildschwein,"fixNr")

wildschwein <- dplyr::select(wildschwein, Tier,DatumUTC,ZeitpUTC,Lat,Long)

wildschwein <- mutate(wildschwein,Tier = str_remove_trailing(Tier,"_"))

wildschwein <- separate(wildschwein, Tier,into = c("TierID","TierName","CollarID"))


wildschwein <- wildschwein %>%
  group_by(TierID) %>%
  mutate(CollarIDfac = LETTERS[as.integer(factor(CollarID))]) %>%
  ungroup() %>%
  mutate(TierID = paste0(TierID,CollarIDfac)) %>%
  select(-CollarIDfac)

wildschwein <- mutate(wildschwein, DatetimeUTC = parse_datetime(ZeitpUTC))

wildschwein <- select(wildschwein, -DatumUTC,-ZeitpUTC)

# warum sind so viele Positionen NA?!
wildschwein <- filter(wildschwein,!is.na(Lat))

# Visualize Points via. lat/long. Note: lat/long are plotted as cartesian coordinates
ggplot(wildschwein, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  coord_fixed(1) +
  theme(legend.position = "none")

wildschwein <- filter(wildschwein,Lat<50)

wildschwein <- filter(wildschwein, TierID != "091A")

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

X = cumsum(rnorm(20))
Y = cumsum(rnorm(20))

plot(X,Y,type = "l") 

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

factpal <- colorFactor(topo.colors(3), wildschwein$stop)

                          
wildschwein[0:500,] %>%
  leaflet() %>%
  addCircles(lng = ~Long, lat = ~Lat, color = ~factpal(stop)) %>%
  addPolylines(lng = ~Long, lat = ~Lat) %>%
  addTiles() %>%
  addLegend(pal = factpal, values = ~stop, title = "Point belongs to stop?")






bbox <- st_bbox(wildschwein_sf)

mcp95 <- mcp_sf(wildschwein_sf,TierID, 95)

mcp95_centeroid <- st_centroid(mcp95)

mcp95_centeroid <- mcp95_centeroid %>%
  st_coordinates() %>%
  as_tibble() %>%
  rename(E = X, N = Y) %>%
  bind_cols(mcp95_centeroid)

ug <- mcp95_centeroid %>%
  mutate(
    ug = ifelse(E>2610000,"ug1","ug2")
  ) %>%
  select(id,ug)


mcp95 <- left_join(mcp95,ug,by = "id")




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





# how many fixes per animal? how many collars per animal? 
wildschwein %>%
  group_by(TierID) %>%
  summarise(
    fixes = n(),
    collars = length(unique(CollarID)),
    names = paste(unique(TierName),collapse = ",")
    )

wildschwein %>%
  group_by(CollarID) %>%
  summarise(
    fixes = n(),
    collars = length(unique(TierID)),
    names = paste(unique(TierName),collapse = ",")
  )

ggplot(wildschwein, aes(DatetimeUTC,TierID, colour = TierID)) +
  geom_line() +
  theme(legend.position = "none")


# what is the sampling interval? 
wildschwein <- wildschwein %>%
  group_by(TierID,CollarID)%>%
  mutate(
    timediffS = as.integer(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs"))
  )

p <- ggplot(wildschwein, aes(timediffS))+
  geom_histogram(binwidth = 10,colour = "black",fill = "white") +
  lims(x = c(0,10*60)) +
  scale_y_continuous(trans = log_trans(), breaks = base_breaks(),labels = prettyNum)

ggplotly(p)




wildschwein %>%
  mutate(
    hour = hour(DatetimeUTC),
    minute = minute(DatetimeUTC),
    hourDec = as.numeric(hour) + as.numeric(minute)/60
  ) %>%
  ggplot(aes(hourDec)) +
  geom_histogram(binwidth = 0.01, fill = "white",colour = "black") +
  lims(x = c(0,01))


wildschwein <- wildschwein %>%
  group_by(TierID,CollarID) %>%
  mutate(
    timediffM = timediffS/60,
    group = cut(timediffM,breaks = c(0,2,50,100,150,200)),
    groupSeq = group == lead(group)
  ) %>%
  ungroup() %>%
  mutate(
    groupSeq = number_groups(groupSeq,include_next = T)
  )


wildschwein %>%
  group_by(TierID,CollarID,groupSeq) %>%
  filter(group == "(0,2]") %>%
  filter(!is.na(groupSeq)) %>%
  mutate(
  steplength1 = euclid(X,Y,lead(X,1),lead(Y,1)),
    timediff1 = as.integer(difftime(lead(DatetimeUTC,1),DatetimeUTC,unit = "secs")),
    speed1 = steplength1/timediff1,
    steplength10 = euclid(X,Y,lead(X,10),lead(Y,10)),
    timediff10 = as.integer(difftime(lead(DatetimeUTC,10),DatetimeUTC,unit = "secs")),
    speed10 = steplength10/timediff10,
    steplength2 = euclid(X,Y,lead(X,2),lead(Y,2)),
    timediff2 = as.integer(difftime(lead(DatetimeUTC,2),DatetimeUTC,unit = "secs")),
    speed2 = steplength2/timediff2,
    steplength3 = euclid(X,Y,lead(X,3),lead(Y,3)),
    timediff3 = as.integer(difftime(lead(DatetimeUTC,3),DatetimeUTC,unit = "secs")),
    speed3 = steplength3/timediff3,
    steplength5 = euclid(X,Y,lead(X,5),lead(Y,5)),
    timediff5 = as.integer(difftime(lead(DatetimeUTC,5),DatetimeUTC,unit = "secs")),
    speed5 = steplength5/timediff5
  ) %>%
  gather(key,timediff,c(timediff1,timediff2,timediff3,timediff5,timediff10)) %>%
  gather(key,speed, c(speed1,speed2,speed3,speed5,speed10)) %>%
  select(-key) %>%
  ggplot(aes(timediff,speed, group = timediff)) +
  geom_boxplot()



wildschwein %>%
  group_by(TierID,CollarID) %>%
  mutate(
    timediffM = timediffS/60,
    date = date(DatetimeUTC),
    dayNr = difftime(date,min(date),units = "days")
  )
  filter(TierID == "015",dayNr %in% 0:50) %>%
  filter(!is.na(groupSeq)) %>%
  # slice(1:200) %>%
  ggplot(aes(DatetimeUTC,timediffM, colour = as.factor(groupSeq))) +
  geom_line() +
  geom_point() +
  scale_y_continuous(breaks = seq(0,200,10))+
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")


wildschwein %>%
  group_by(TierID,CollarID) %>%
  mutate(
    timediffM = timediffS/60,
    date = date(DatetimeUTC),
    dayNr = difftime(date,min(date),units = "days"),
    samplegr = timediffM>120
  ) %>%
  filter(TierID == "015",dayNr %in% 15:16) %>%
  ggplot(aes(X,Y,colour = samplegr)) +
  geom_point() 

# Leaflet 
factpal <- colorFactor(topo.colors(length(levels(cp@data$id))), cp@data$id)

leaflet(cp) %>%
  addPolygons(popup = paste("ID: ",cp@data$id), color = ~factpal(cp@data$id)) %>%
  addTiles()




# 
# wildschwein %>%
#   # filter(TierID == "015") %>%
#   mutate(timediff = as.numeric(difftime(DatetimeUTC,lag(DatetimeUTC),units = "mins"))) %>%
#   # dplyr::select(timediff) %>%
#   ggplot(aes(timediff)) +
#   geom_histogram(binwidth = 1,fill = "grey", colour= "blue") +
#   scale_y_log10() +
#   facet_wrap(~TierID)
# 
# wildschwein %>%
#   mutate(
#     timediffMins = as.integer(timediffSecs/60)
#     ) %>%
#   group_by(TierID,timediffMins) %>%
#   summarise(n = n()) %>%
#   ggplot(aes(timediffMins,n)) +
#   geom_point()
# 
# 
# 
# 
# ggplot(wildschwein, aes(timediffSecs,speedMS, colour = TierID)) +
#   geom_point() +
#   scale_x_continuous(limits = c(0,500)) +
#   facet_wrap(~TierID)

# wildschwein %>%
#   filter(TierID == "039") %>%
#   ggplot(aes(timediffSecs,speedMS, colour = TierID)) +
#   geom_point() +
#   scale_x_continuous(limits = c(0,500)) +
#   facet_wrap(~TierID)


#############################################################################
## Lesson 3 #################################################################
#############################################################################

# - Matt's students package
# - Compute similarities between trajectories (similarity measure from leiden workshop?!)
# 
# Introduction of Rmarkdown for Project?


#############################################################################
## Lesson 4 #################################################################
#############################################################################
# - Operationalize and find meet patterns 
# - Visualize spatial distribution of meet
# - Define functions


#############################################################################
## Lesson 5 #################################################################
#############################################################################
# - enrich trajectories with R (overlay)
# - attach context (land-use, slope) to trajectories, 
# - search for correlations (speed vs. slope, speed vs. landUse). BSc Tomlinson
# - Mapmatching MTB tracks on paths
# - Area centered analysis (MCP, DU, KDE, home range)
