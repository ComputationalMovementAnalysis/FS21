library(tidyverse)
library(plotly)
library(CMAtools)
library(recurse)
## Input: cut vecotrs by intervals ####################
ages <- c(20,25,18,13,53,50,23,43,68,40)
breaks <- seq(0,50,10)

cut(ages,breaks = breaks)

library(CMAtools)

breaks <- c(0,30,60,100)

cut(ages, breaks = breaks, labels = c("young","middle aged","old"))

cut(ages, breaks = breaks, labels = labels_nice(breaks))


## Task 2 ####################

breaks <- c(0,40,80,300,600,1200,2500,3000,4000,7500,110000)


ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 10) +
  lims(x = c(0,600)) +
  scale_y_log10() +
  geom_vline(xintercept = breaks, col = "red")

ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 10) +
  lims(x = c(600,1200)) +
  scale_y_log10() +
  geom_vline(xintercept = breaks, col = "red")


ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 10) +
  lims(x = c(1200,10000)) +
  scale_y_log10() +
  geom_vline(xintercept = breaks, col = "red")


wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    samplingInt = cut(timelag,breaks = breaks,labels = labels_nice(breaks))
  ) 

# wildschwein_BE %>%
#   as.data.frame() %>%
#   group_by(samplingInt) %>%
#   summarise(
#     n = n()
#   ) %>%
#   ggplot(aes(samplingInt,n)) +
#   geom_bar(stat = "identity") +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#   scale_y_log10()

# Todo: diesen Plot entfernen?
## Task 1 ####################

nMinus2 <- euclid(lag(X, 2),lag(Y, 2),X,Y)  # distance to pos. -10 minutes
nMinus1 <- euclid(lag(X, 1),lag(Y, 1),X,Y)  # distance to pos.  -5 minutes
nPlus1  <- euclid(X,Y,lead(X, 1),lead(Y, 1)) # distance to pos   +5 mintues
nPlus2  <- euclid(X,Y,lead(X, 2),lead(Y, 2)) # distance to pos  +10 minutes

# Use cbind to bind all rows to a matrix
distances <- cbind(nMinus2,nMinus1,nPlus1,nPlus2)
distances

# This just gives us the overall mean
mean(distances, na.rm = T)

# We therefore need the function `rowMeans()`
rowmeans <- rowMeans(distances)
cbind(distances,rowmeans)

# and if we put it all together:
rowMeans(
  cbind(
    euclid(lag(X, 2),lag(Y, 2),X,Y),
    euclid(lag(X, 1),lag(Y, 1),X,Y),  
    euclid(X,Y,lead(X, 1),lead(Y, 1)), 
    euclid(X,Y,lead(X, 2),lead(Y, 2))
  )
)

## Task 2 ####################

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
## Task 3 ####################


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

sample <- data.frame(position = paste0("pos",1:6),samplingInt=c(rep(60,3),rep(120,3)))
sample
sample <- sample %>%
  mutate(
    samplingInt_control = samplingInt == lead(samplingInt,1),
    samplingInt_group = number_groups(samplingInt_control,include_first_false = T)
  )

sample
wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    samplingInt_T = samplingInt == lead(samplingInt),
    group = number_groups(samplingInt_T,include_first_false = T)
  ) %>%
  dplyr::select(-samplingInt_T)
## # library(leaflet)
## # library(scales)
## # factpal <- colorFactor(hue_pal()(2), wildschwein_BE_sf$moving)
## #
## # # checking to see if this all makes sense in leaflet: (or better ggplot?)
## # wildschwein_BE_sf[0:200,] %>%
## #   filter(!is.na(moving)) %>%
## #   leaflet() %>%
## #   addCircles(radius = 1,lng = ~Long, lat = ~Lat, color = ~factpal(moving)) %>%
## #   addPolylines(opacity = 0.1,lng = ~Long, lat = ~Lat) %>%
## #   addTiles() %>%
## #   addLegend(pal = factpal, values = ~moving, title = "Animal moving?")

## Task 5 #######################

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

## wildschwein_BE <- mutate(wildschwein_BE,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")))
## 
## summary(wildschwein_BE$timelag)
