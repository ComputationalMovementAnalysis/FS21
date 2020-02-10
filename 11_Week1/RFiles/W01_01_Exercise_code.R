#- header3 Task1
#- chunkstart


# Loading enironment / libraries ####
library(tidyverse)



# Data import ####

# Data clensing ####

# Data analysis and visualization ####


#- chunkend

#- header3 Task 2
#- chunkstart


# Data import ####
wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")


# Check Timezone
attr(wildschwein_BE$DatetimeUTC,"tzone") # or
wildschwein_BE$DatetimeUTC[1]

#- chunkend

#- header3 Task 3
#- chunkstart

ggplot(wildschwein_BE, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  coord_map() +
  theme(legend.position = "none")

#- chunkend

#- header3 Input
#- chunkstart

library(sf)

wildschwein_BE_sf <- st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326)


wildschwein_BE

wildschwein_BE_sf





wildschwein_BE = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326)

rm(wildschwein_BE_sf) # we can remove this sf object, since it just eats up our memory


#- chunkend

#- header3 Task 4
#- chunkstart


wildschwein_BE <- st_transform(wildschwein_BE, 2056)



wildschwein_BE

#- chunkend

#- header3 Input
#- chunkstart

wildschwein_BE_grouped <- group_by(wildschwein_BE,TierID)

wildschwein_BE_grouped


wildschwein_BE_smry <- summarise(wildschwein_BE_grouped)

wildschwein_BE_smry


mcp <- st_convex_hull(wildschwein_BE_smry)


#- chunkend

#- header3 Task 5
#- chunkstart

plot(mcp)

ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4)

ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4) +
  coord_sf(datum = 2056)

#- chunkend

#- header3 Input
#- chunkstart


library(raster)

pk100_BE <- brick("00_Rawdata/pk100_BE_2056.tif")

pk100_BE


plot(pk100_BE)

pk100_BE <- subset(pk100_BE,1:3)

plot(pk100_BE)


#- chunkend

#- header3 Task 6
#- chunkstart

library(tmap)


tm_shape(pk100_BE) + 
  tm_rgb() 


tm_shape(pk100_BE) + 
  tm_rgb() +
  tm_shape(mcp) +
  tm_polygons(col = "TierID",alpha = 0.4,border.col = "red") +
  tm_legend(bg.color = "white")



## 
## tmap_mode("view")
## 
## tm_shape(mcp) +
##   tm_polygons(col = "TierID",alpha = 0.4,border.col = "red") +
##   tm_legend(bg.color = "white")

#- chunkend
