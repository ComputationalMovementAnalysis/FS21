
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

wildschwein_BE_sf = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326, agr = "constant")

## Task 4 (Continued) ########

wildschwein_BE_sf <- st_transform(wildschwein_BE_sf, 2056)

coordinates <- st_coordinates(wildschwein_BE_sf)

colnames(coordinates) <- c("E","N")

wildschwein_BE <- cbind(wildschwein_BE,coordinates)

## NA
