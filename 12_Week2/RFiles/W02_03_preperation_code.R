## Preperation #################################################################



library(tidyverse)
library(sf)
library(lubridate)

wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")

wildschwein_BE = st_as_sf(wildschwein_BE, 
                          coords = c("Long", "Lat"), 
                          crs = 4326)

wildschwein_BE <- st_transform(wildschwein_BE, 2056)
