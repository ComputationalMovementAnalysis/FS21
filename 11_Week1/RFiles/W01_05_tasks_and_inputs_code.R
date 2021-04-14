
library(sf)

wildschwein_BE_sf <- st_as_sf(wildschwein_BE, 
                              coords = c("Long", "Lat"), 
                              crs = 4326)


wildschwein_BE

wildschwein_BE_sf





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




library(raster)

pk100_BE <- brick("00_Rawdata/pk100_BE_2056.tif")

pk100_BE


plot(pk100_BE)

pk100_BE <- subset(pk100_BE,1:3)

plot(pk100_BE)


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
