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
wildschwein_BE <- read_delim("../CMA_FS2018_Filestorage/wildschwein_BE.csv",",")


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
wildschwein_BE = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326,remove = FALSE)

wildschwein_BE # note how the Lat/Long information is stored twice

rm(wildschwein_BE_sf) # we can remove this sf object, since it just eats up our memory

#- chunkend
#- header3 Task 4
#- chunkstart

wildschwein_BE <- st_transform(wildschwein_BE, 2056)


wildschwein_BE
#- chunkend
#- header3 Input
#- chunkstart
wildschwein_BE <- group_by(wildschwein_BE,TierID)
wildschwein_BE
mcp <- st_convex_hull(summarise(wildschwein_BE))

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
#- header3 Task 6
#- chunkstart

library(raster)
library(ggspatial)

pk100_BE <- brick("../CMA_FS2018_Filestorage/pk100_BE_2056.tif")

ggplot(mcp,aes(fill = TierID)) +
  geom_spraster_rgb(pk100_BE, interpolate = TRUE) +
  geom_sf(alpha = 0.4) +
  coord_sf(datum = 2056) +
  theme(
    legend.position = "none",
    panel.grid.major = element_line(colour = "transparent"),
    panel.background = element_rect(fill = "transparent"),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
    )

#- chunkend
