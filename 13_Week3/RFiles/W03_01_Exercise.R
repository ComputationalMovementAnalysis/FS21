library(tidyverse)
library(plotly)
library(CMAtools)
library(recurse)

## Task 1 ####################

wildschwein_BE_sf <- wildschwein_BE_sf %>%
  group_by(TierID) %>%
  mutate(
    stepMean = rowMeans(
      cbind(
        euclid(lag(E, 2),lag(N, 2),E,N),
        euclid(lag(E, 1),lag(N, 1),E,N),
        euclid(E,N,lead(E, 1),lead(N, 1)),
        euclid(E,N,lead(E, 2),lead(N, 2))
        )
      )
  )
## Task 2 ####################


summary(wildschwein_BE_sf$stepMean)

ggplot(wildschwein_BE_sf, aes(stepMean)) +
  geom_histogram(binwidth = 1) +
  lims(x = c(0,100)) +
  geom_vline(xintercept = 15)


wildschwein_BE_sf <- wildschwein_BE_sf %>%
  mutate(
    moving = stepMean > 15
  )

wildschwein_BE_sf[20:50,] %>%
  filter(!is.na(moving)) %>%
  ggplot() +
  geom_sf(aes(colour = moving)) +
  geom_path(aes(E,N)) +
  coord_sf(datum = 2056) +
  theme(
    panel.grid.major = element_line(colour = "transparent"),
    panel.background = element_rect(fill = "transparent")
    ) 

## library(leaflet)
## library(scales)
## factpal <- colorFactor(hue_pal()(2), wildschwein_BE_sf$moving)
## 
## # checking to see if this all makes sense in leaflet: (or better ggplot?)
## wildschwein_BE_sf[0:200,] %>%
##   filter(!is.na(moving)) %>%
##   leaflet() %>%
##   addCircles(radius = 1,lng = ~Long, lat = ~Lat, color = ~factpal(moving)) %>%
##   addPolylines(opacity = 0.1,lng = ~Long, lat = ~Lat) %>%
##   addTiles() %>%
##   addLegend(pal = factpal, values = ~moving, title = "Animal moving?")

library(recurse)
library(ggforce)

recurs <- wildschwein_BE_sf %>% 
  filter(TierID == "001A") %>%
  select(E,N,DatetimeUTC,TierID) %>%
  st_set_geometry(NULL) %>%
  as.data.frame() %>%
  getRecursions(100)

recurStats <- recurs$revisitStats

recurStats <- recurStats %>%
  group_by(coordIdx) %>%
  summarise(
    number_of_visits = max(visitIdx),
    x = unique(x),
    y = unique(y),
    total_time = sum(timeInside),
    max_time = max(timeInside),
    mean_time = mean(timeInside)
  )

data1 = filter(recurStats, number_of_visits > 30)
wildschwein_BE_sf %>%
  ungroup() %>%
  filter(TierID == "001A") %>%
  ggplot(aes(E,N)) +
  geom_point(alpha = 0.4, colour = "grey") +
  geom_circle(data = data1, alpha = 0.5, aes(x0 = x,y0 = y,fill = mean_time,r = 100),inherit.aes = F) +
  coord_fixed(1)

## NA
