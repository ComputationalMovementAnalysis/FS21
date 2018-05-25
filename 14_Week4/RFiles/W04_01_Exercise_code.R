#- header3 Preperation
#- chunkstart
## devtools::install_git("https://github.engineering.zhaw.ch/PatternsTrendsEnvironmentalData/CMAtools.git") # Reinstall this package, since we have a few updates
## 
## install.packages("ggpmisc") # you   dont really need this package. We just use it to add layers at specific positions
library(tidyverse)
library(CMAtools)
library(sf)

# Import as tibble
wildschwein_BE <- read_delim("../CMA_FS2018_Filestorage/wildschwein_BE.csv",",")

# Convert to sf-object
wildschwein_BE = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326,remove = FALSE)

# transform to CH1903 LV95
wildschwein_BE <- st_transform(wildschwein_BE, 2056)

# Add geometry as E/N integer Columns
wildschwein_BE <- st_coordinates(wildschwein_BE) %>%
  cbind(wildschwein_BE,.) %>%
  rename(E = X) %>%
  rename(N = Y)

# Compute timelag, steplength and speed
wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = euclid(lead(E, 1),lead(N, 1),E,N),
    speed = steplength/timelag
  )

#- chunkend
#- header3 Task 1
#- chunkstart

library(raster)
library(ggspatial)


pk100_BE <- brick("../CMA_FS2018_Filestorage/pk100_BE_2056.tif")

wildschwein_fil <- wildschwein_BE %>%
  filter(as.Date(DatetimeUTC) >= as.Date("2014-10-26")) %>%
  filter(as.Date(DatetimeUTC) <= as.Date("2014-10-27"))


ggplot(wildschwein_fil, aes(colour = TierID)) +
  annotation_spraster(pk100_BE) +
  geom_sf(size = 4) +
  coord_sf(datum = 2056)

wildschwein_fil <- wildschwein_fil %>%
  filter(TierID != "005A")

#- chunkend
#- header3 Input
#- chunkstart

euclid <- function(x1,y1,x2,y2){
  distance <- sqrt((x1-x2)^2+(y1-y2)^2)
  return(distance)
}

#- chunkend
#- header3 Task 2
#- chunkstart

# round a number to a multiple of another number

minutes <- 1:60
multiple <- 15
round(minutes/multiple)*multiple


y <- Sys.time()
y
class(y)

x <- as.POSIXlt(y) # Turns a POSIXct into POSIXlt
x
x[["min"]]                  # retrieves minutes of POSIXlt
x[["min"]] <- 40            # sets minutes of POSIXlt
x

# Gets minutes as a decimal value
min_decimal <- x[["min"]] + x[["sec"]]/60

round_minutes_to <- function(datetime, multiple){
  datetime2 <- as.POSIXlt(datetime)
  min_decimal <- datetime2[["min"]] + datetime2[["sec"]]/60
  min_round <- round(min_decimal/multiple)*multiple
  datetime2[["min"]] <- min_round
  datetime2[["sec"]] <- 0
  datetime2 <- as.POSIXct(datetime2)
  return(datetime2)
}

#- chunkend
#- header3 Task 3
#- chunkstart
ggplot(wildschwein_fil, aes(DatetimeUTC,timelag/60, colour = TierID)) + 
  geom_line() + 
  expand_limits(y = 0)



wildschwein_fil <- wildschwein_fil %>%
  group_by(TierID) %>%
  mutate(
    DatetimeRound = round_minutes_to(DatetimeUTC,15),
    E_interpol = linear_interpol(DatetimeUTC,DatetimeRound,E),
    N_interpol = linear_interpol(DatetimeUTC,DatetimeRound,N)
  )

wildschwein_fil %>%
  as.data.frame() %>%
  slice(30:40) %>%
  ggplot() +
  geom_point(aes(E,N,colour = "original")) +
  geom_path(aes(E,N,colour = "original")) +
  geom_point(aes(E_interpol, N_interpol,colour = "interpolated"),lty = 2) +
  geom_path(aes(E_interpol, N_interpol,colour = "interpolated"),lty = 2) +
  coord_equal() +
  theme(legend.position = "bottom",legend.direction = "horizontal",legend.title = element_blank())



#- chunkend
#- header3 Task 4
#- chunkstart
# get unique IDs for my filtered dataframe
ids <- wildschwein_fil %>%
  as.data.frame() %>%
  group_by(TierID) %>%
  summarise() %>%
  pull()                  # pull() turns my single column dataframe into a vector



# map() creates a list of dataframes
wildschwein_fil_L <- ids %>%
  map(function(x){
    wildschwein_fil %>%
      as.data.frame() %>%
      filter(TierID == x) %>%
      dplyr::select(-c(geometry,TierName,CollarID,timelag)) %>%
      rename_at(vars(-matches("DatetimeRound")),paste0,"_",which(ids== x))
    })
#- chunkend
#- header3 Task 5
#- chunkstart

wildschwein_join <- wildschwein_fil_L %>%
  Reduce(function(dtf1,dtf2) full_join(dtf1,dtf2,by="DatetimeRound"), .) %>%
  arrange(DatetimeRound)

wildschwein_join <- wildschwein_join %>%
  mutate(
    dist12 = euclid(E_1,N_1,E_2,N_2),
    dist13 = euclid(E_1,N_1,E_3,N_3),
    dist23 = euclid(E_2,N_2,E_3,N_3)
  )

meets <- wildschwein_join %>%
  gather(key,val,c(dist12,dist13,dist23)) %>%
  filter(val < 150) %>%
  spread(key,val)

meets
#- chunkend
#- header3 Task 6
#- chunkstart

library(ggpmisc)

pk25 <- brick("../CMA_FS2018_Filestorage/pk25.tif")
swissimage <- brick("../CMA_FS2018_Filestorage/swissimage_250cm.tif")

p4 <- wildschwein_fil %>%
  filter(TierID %in% c("010B","011A")) %>%
  ggplot(aes(colour = TierID)) +
  geom_point(aes(E,N),alpha = 0.2) +
  geom_path(aes(E,N),alpha = 0.2) +
  geom_segment(data = meets, aes(x = E_2,y = N_2,xend = E_3,yend = N_3, colour = "Meet"),inherit.aes = F,lwd = 3,alpha = 0.4) +
  coord_sf(datum = 2056,ylim = c(1204000,1205000))

append_layers(p4, annotation_spraster(pk25), position = "bottom")


append_layers(p4, annotation_spraster(swissimage), position = "bottom")

#- chunkend
#- header3 Task 7 (Optional)
#- chunkstart
## 
## library(leaflet)
## library(scales)
## 
## factpal <- colorFactor(hue_pal()(3), wildschwein_fil$TierID)
## 
## wildschwein_fil_line <- wildschwein_fil %>%
##   summarise(do_union = FALSE) %>%
##   st_cast("LINESTRING") %>%
##   st_transform(4326)
## 
## leaflet(wildschwein_fil) %>%
##   addProviderTiles(providers$Esri.WorldImagery) %>%
##   addPolylines(data = wildschwein_fil_line,color = ~factpal(TierID)) %>%
##   addCircles(data = meets,radius = 8,lng = ~Long_2, lat = ~Lat_2,opacity = 0,fillOpacity = 1,fillColor = "blue") %>%
##   addCircles(data = meets,radius = 8,lng = ~Long_3, lat = ~Lat_3,opacity = 0,fillOpacity = 1,fillColor = "red") %>%
##   addLegend(pal = factpal, values = ~TierID, title = "TierID")
## 
## 
## 
#- chunkend
#- header3 Task 8
#- chunkstart
## 
## library(scales)
## pal <- hue_pal()(5)
## pal <- c("red","yellow","green")
## 
## library(plotly)
## plot_ly(wildschwein_join, x = ~E_1,y = ~N_1, z = ~DatetimeRound,type = "scatter3d", mode = "lines") %>%
##   add_trace(wildschwein_join, x = ~E_2,y = ~N_2, z = ~DatetimeRound) %>%
##   add_trace(wildschwein_join, x = ~E_3,y = ~N_3, z = ~DatetimeRound) %>%
##   add_markers(data = meets, x = ~E_2,y = ~N_2, z = ~DatetimeRound) %>%
##   add_markers(data = meets, x = ~E_3,y = ~N_3, z = ~DatetimeRound) %>%
##   layout(scene = list(xaxis = list(title = 'E'),
##                       yaxis = list(title = 'N'),
##                       zaxis = list(title = 'Time')))
## 
#- chunkend
