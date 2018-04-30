## install.packages("tidyverse")
## install.packages("devtools")
## devtools::install_github("tidyverse/ggplot2")
## 
## # run the following line only if you are working on RStudio Server
## install.packages('udunits2', type = "source", repo = "cran.rstudio.com", configure.args="--with-udunits2-include=/usr/include/udunits2")
## 
## install.packages("sf")
## 
## 
## 
## install.packages("raster")
## install.packages("ggspatial")

# Loading enironment / libraries ####
library(tidyverse)



# Data import ####

# Data clensing ####

# Data analysis and visualization ####



## Task 2 ####################


# Data import ####
wildschwein_BE <- read_delim("../CMA_FS2018_Filestorage/wildschwein_BE.csv",",")


# Check Timezone
attr(wildschwein_BE$DatetimeUTC,"tzone") # or
wildschwein_BE$DatetimeUTC[1]

## Task 3 ####################
ggplot(wildschwein_BE, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  coord_map() +
  theme(legend.position = "none")
## Input: Handling spatial data ####################

library(sf)

wildschwein_BE_sf <- st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326)

wildschwein_BE

wildschwein_BE_sf
is.data.frame(wildschwein_BE_sf)
## # subset rows
## wildschwein_BE_sf[1:10,]
## wildschwein_BE_sf[wildschwein_BE_sf$TierName == "Ueli",]
## 
## # subset colums
## wildschwein_BE_sf[,2:3]
wildschwein_BE = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326,remove = FALSE)

wildschwein_BE # note how the Lat/Long information is stored twice

rm(wildschwein_BE_sf) # we can remove this sf object, since it just eats up our memory


## Task 4 ####################

wildschwein_BE <- st_transform(wildschwein_BE, 2056)


wildschwein_BE
## Input: Convex Hull ####################
wildschwein_BE <- group_by(wildschwein_BE,TierID)
wildschwein_BE
mcp <- st_convex_hull(summarise(wildschwein_BE))

## Task 5 ####################
plot(mcp)
ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4)
ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4) +
  coord_sf(datum = 2056)

## Task 6 ####################


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

wildschwein_BE <- group_by(wildschwein_BE,TierID)
## wildschwein_BE <- mutate(wildschwein_BE,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")))
## 
## summary(wildschwein_BE$timelag)
