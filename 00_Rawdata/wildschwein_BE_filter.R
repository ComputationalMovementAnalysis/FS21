
library(tidyverse)


## Importing the Oirinal data ##################################################
# (is not part of the git repo and therefore not reproducible)

# wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE_all.csv",",")
# 
# 
# wildschwein_BE %>%
#   ggplot(aes(DatetimeUTC,TierID, colour = TierID)) +
#   geom_point() +
#   facet_wrap(~TierName, ncol = 1, scales = "free_y")
# 
# unique(wildschwein_BE$TierName)
# 
# wildschwein_BE <- wildschwein_BE %>%
#   filter(TierName %in% c("Rosa","Ruth","Sabi"))
# 
# 
# write_delim(wildschwein_BE,"00_Rawdata/wildschwein_BE.csv",",")


## Writing out wildschwein_BE_2056.csv #########################################

library(tmap)
library(readr)
library(sf)
library(dplyr)


wildschwein_BE <- read_csv("00_Rawdata/wildschwein_BE.csv") %>%
  st_as_sf(coords = c("Long","Lat"), crs = 4326)


wildschwein_BE_2056 <- st_transform(wildschwein_BE, 2056)


tm_shape(st_as_sfc(st_bbox(wildschwein_BE_2056))) + tm_polygons()

wildschwein_2056 %>%
  cbind(st_coordinates(.)) %>%
  st_drop_geometry() %>%
  rename(E = X, N = Y) %>%
  write_csv("00_Rawdata/wildschwein_BE_2056.csv")





## Writing out caro60 for ex 2 #################################################
library(tmap)
library(readr)
library(sf)
library(dplyr)


wildschwein_BE <- read_csv("00_Rawdata/wildschwein_BE.csv") %>%
  st_as_sf(coords = c("Long","Lat"), crs = 4326)

wildschwein_BE %>%
  mutate(timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")))%>%
  filter(timelag > 40, timelag < 70) %>%
  select(-timelag) %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326) %>%
  st_transform(2056) %>%
  cbind(st_coordinates(.)) %>%
  rename(E = X, N = Y) %>%
  st_set_geometry(NULL) %>%
  head(200) %>%
  write_delim("00_Rawdata/caro60.csv",",")
  



  