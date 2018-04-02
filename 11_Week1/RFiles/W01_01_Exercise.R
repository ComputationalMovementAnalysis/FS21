
## Task 1 ####################


# Loading enironment / libraries ####

# install.packages("tidyverse")
library(tidyverse)
library(sf)



## Task 2 ####################


# Data import ####
wildschwein_BE <- read_delim("../Geodata/wildschwein_BE.csv",",")

## Task 3 ####################


ggplot(wildschwein_BE, aes(Lat,Long, colour = TierID)) +
  geom_point() +
  coord_fixed(1) +
  theme(legend.position = "none")

wildschwein_BE <- filter(wildschwein_BE, Lat < 50)

## Task 4 ####################

wildschwein_BE_sf = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326, agr = "constant", remove = F)


wildschwein_BE_sf <- st_transform(wildschwein_BE_sf, 2056)


mcp <- wildschwein_BE_sf %>%
  group_by(TierID) %>%
  summarise() %>%
  st_convex_hull()

ggplot(mcp,aes(fill = TierID)) +
  geom_sf(alpha = 0.4) +
  coord_sf(datum = 2056) +
  theme(
    legend.position = "none",
    panel.grid.major = element_line(colour = "transparent"),
    panel.background = element_rect(fill = "transparent")
    )



coordinates <- st_coordinates(wildschwein_BE_sf)

colnames(coordinates) <- c("E","N")

wildschwein_BE_sf <- cbind(wildschwein_BE_sf,coordinates)

## NA
