library(tidyverse)






library(sf)

wildschwein_BE_sf <- st_as_sf(wildschwein_BE, 
                              coords = c("Long", "Lat"), 
                              crs = 4326)


wildschwein_BE

wildschwein_BE_sf

is.data.frame(wildschwein_BE_sf)

# subset rows
wildschwein_BE_sf[1:10,]
wildschwein_BE_sf[wildschwein_BE_sf$TierName == "Sabi",]

# subset colums
wildschwein_BE_sf[,2:3]

wildschwein_BE <- st_as_sf(wildschwein_BE, 
                          coords = c("Long", "Lat"), 
                          crs = 4326)

rm(wildschwein_BE_sf) 
# we can remove this sf object, since it just eats up our memory




wildschwein_BE


wildschwein_BE_grouped <- group_by(wildschwein_BE,TierID)

wildschwein_BE_grouped


wildschwein_BE_smry <- summarise(wildschwein_BE_grouped)

wildschwein_BE_smry


mcp <- st_convex_hull(wildschwein_BE_smry)


plot(mcp)




library(terra)

pk100_BE <- terra::rast("00_Rawdata/pk100_BE_2056.tif")

pk100_BE


plot(pk100_BE)

pk100_BE <- subset(pk100_BE,1:3)

plot(pk100_BE)


library(tmap)

tm_shape(pk100_BE) + 
  tm_rgb() 

