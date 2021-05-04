
## Solutions




Hover over the code and copy the content by clicking on the clipboard icon on the top right. You can now paste this into an R-Script.



```r
# task 1 ########################################################################

# Data import ####
wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")


# Check Timezone
attr(wildschwein_BE$DatetimeUTC,"tzone") # or
wildschwein_BE$DatetimeUTC[1]


# task 2 ########################################################################

ggplot(wildschwein_BE, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  coord_map() +
  theme(legend.position = "none")


# task 3 ########################################################################

wildschwein_BE <- st_transform(wildschwein_BE, 2056)


# task 4 ########################################################################


ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4)

ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4) +
  coord_sf(datum = 2056)


# task 5 ########################################################################

library(tmap)


tm_shape(pk100_BE) + 
  tm_rgb() 


tm_shape(pk100_BE) + 
  tm_rgb() +
  tm_shape(mcp) +
  tm_polygons(col = "TierID",alpha = 0.4,border.col = "red") +
  tm_legend(bg.color = "white")


# task 6 ########################################################################

tmap_mode("view")

tm_shape(mcp) +
  tm_polygons(col = "TierID",alpha = 0.4,border.col = "red") +
  tm_legend(bg.color = "white")
```

