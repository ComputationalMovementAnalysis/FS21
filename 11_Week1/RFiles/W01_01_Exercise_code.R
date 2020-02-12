
## Task 1 ######################################################################

# Loading enironment / libraries ####
library(tidyverse)



# Data import ####

# Data clensing ####

# Data analysis and visualization ####


## Task 2 ######################################################################

# Data import ####
wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")


# Check Timezone
attr(wildschwein_BE$DatetimeUTC,"tzone") # or
wildschwein_BE$DatetimeUTC[1]

## Task 3 ######################################################################


ggplot(wildschwein_BE, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  theme(legend.position = "none")

## Input Handling Spatial Data #################################################


library(sf)

wildschwein_BE_sf <- st_as_sf(wildschwein_BE, 
                              coords = c("Long", "Lat"), 
                              crs = 4326)


wildschwein_BE

wildschwein_BE_sf





wildschwein_BE = st_as_sf(wildschwein_BE, 
                          coords = c("Long", "Lat"), 
                          crs = 4326)

rm(wildschwein_BE_sf) 
# we can remove this sf object, since it just eats up our memory


## Task 4 ######################################################################


wildschwein_BE <- st_transform(wildschwein_BE, 2056)



wildschwein_BE

## Input: Calculate Convex Hull ################################################


wildschwein_BE_grouped <- group_by(wildschwein_BE,TierID)

wildschwein_BE_grouped


wildschwein_BE_smry <- summarise(wildschwein_BE_grouped)

wildschwein_BE_smry


mcp <- st_convex_hull(wildschwein_BE_smry)


## Task 5 ######################################################################

plot(mcp)

ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4)

ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4) +
  coord_sf(datum = 2056)

## Input: Importing Raster Data ################################################


library(raster)

pk100_BE <- brick("00_Rawdata/pk100_BE_2056.tif")

pk100_BE


plot(pk100_BE)

pk100_BE <- subset(pk100_BE,1:3)

plot(pk100_BE)


## Task 6 ######################################################################

library(tmap)


tm_shape(pk100_BE) + 
  tm_rgb() 


tm_shape(pk100_BE) + 
  tm_rgb() +
  tm_shape(mcp) +
  tm_polygons(col = "TierID",alpha = 0.4,border.col = "red") +
  tm_legend(bg.color = "white")



## ## Task 7 ######################################################################


## 
## tmap_mode("view")
## 
## tm_shape(mcp) +
##   tm_polygons(col = "TierID",alpha = 0.4,border.col = "red") +
##   tm_legend(bg.color = "white")
