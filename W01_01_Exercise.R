## ----task 1--------------------------------------------------------------

# Loading enironment / libraries ####
library(tidyverse)



# Data import ####

# Data clensing ####

# Data analysis and visualization ####



## ----task2---------------------------------------------------------------

# Data import ####
wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")


# Check Timezone
attr(wildschwein_BE$DatetimeUTC,"tzone") # or
wildschwein_BE$DatetimeUTC[1]


## ----task3, echo = F, include=T, eval = T--------------------------------
ggplot(wildschwein_BE, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  theme(legend.position = "none")


## ----input_handlingSpatialData, echo = T, include = T, eval = T----------
library(sf)

wildschwein_BE_sf <- st_as_sf(wildschwein_BE, 
                              coords = c("Long", "Lat"), 
                              crs = 4326)



## ----  echo = T, include = T, eval = T, collapse=F-----------------------
wildschwein_BE

wildschwein_BE_sf






## ----  echo = T, include = T, eval = T-----------------------------------
wildschwein_BE = st_as_sf(wildschwein_BE, 
                          coords = c("Long", "Lat"), 
                          crs = 4326)

rm(wildschwein_BE_sf) 
# we can remove this sf object, since it just eats up our memory



## ----task4---------------------------------------------------------------

wildschwein_BE <- st_transform(wildschwein_BE, 2056)




## ---- echo = F, include=T,eval = T---------------------------------------
wildschwein_BE


## ----input_calculateConvexHull, echo = T,include = T,eval = T------------
wildschwein_BE_grouped <- group_by(wildschwein_BE,TierID)

wildschwein_BE_grouped



## ---- echo = T,include = T,eval = T--------------------------------------
wildschwein_BE_smry <- summarise(wildschwein_BE_grouped)

wildschwein_BE_smry



## ---- echo = T,include = T,eval = T--------------------------------------
mcp <- st_convex_hull(wildschwein_BE_smry)



## ----task5, echo = T,include = T,eval = T--------------------------------
plot(mcp)


## ---- echo = F,include = T,eval = T--------------------------------------
ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4)


## ---- echo = F,include = T,eval = T--------------------------------------
ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4) +
  coord_sf(datum = 2056)


## ----inputImportingRasterData, echo = T,include = T,eval = T-------------

library(raster)

pk100_BE <- brick("00_Rawdata/pk100_BE_2056.tif")

pk100_BE


## ---- echo = T,include = T,eval = T--------------------------------------

plot(pk100_BE)

pk100_BE <- subset(pk100_BE,1:3)

plot(pk100_BE)



## ------------------------------------------------------------------------
#- chunkend


## ----task6, echo = T,include = T,eval = T--------------------------------
library(tmap)


tm_shape(pk100_BE) + 
  tm_rgb() 



## ---- echo = F,include = T,eval = T--------------------------------------
tm_shape(pk100_BE) + 
  tm_rgb() +
  tm_shape(mcp) +
  tm_polygons(col = "TierID",alpha = 0.4,border.col = "red") +
  tm_legend(bg.color = "white")




## ----task7, echo = F,include = T,eval = F--------------------------------
## 
## tmap_mode("view")
## 
## tm_shape(mcp) +
##   tm_polygons(col = "TierID",alpha = 0.4,border.col = "red") +
##   tm_legend(bg.color = "white")

