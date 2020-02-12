## 
library(tidyverse)
library(sf)

# Import as tibble
wildschwein_BE <- read_delim("../CMA_FS2018_Filestorage/wildschwein_BE.csv",",")

# Convert to sf-object
wildschwein_BE = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326,remove = FALSE)

# transform to CH1903 LV95
wildschwein_BE <- st_transform(wildschwein_BE, 2056)

# Add geometry as E/N integer Columns
wildschwein_BE <- st_coordinates(wildschwein_BE) %>%
  cbind(wildschwein_BE,.) %>%
  rename(E = X) %>%
  rename(N = Y)

# Compute timelag, steplength and speed
wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = euclid(lead(E, 1),lead(N, 1),E,N),
    speed = steplength/timelag
  )


library(lubridate)

fanel2016 <- read_sf("../CMA_FS2018_Filestorage/Kulturen/Feldaufnahmen_Fanel_2016.shp") %>%
  st_transform(2056)

wildschwein_BE_2016 <- wildschwein_BE %>%
  filter(DatetimeUTC >= as.Date("2016-04-01")) %>%
  filter(DatetimeUTC <= as.Date("2016-09-30"))


ggplot(fanel2016, aes(fill = Frucht)) + 
  annotation_spraster(pk100_BE) +
  geom_sf(alpha = 0.3) +
  geom_sf(data = mcp2016, aes(colour = TierID), inherit.aes = F, alpha = 0.1,lwd = 2) +
  theme(legend.position = "bottom")
  
wildschwein_BE_2016 <- wildschwein_BE_2016 %>%
  st_join(select(fanel2016,Frucht))


frucht_remove <- c("0","Flugplatz","Rhabarber","Zucchetti")

wildschwein_BE_2016 %>%
  as.data.frame() %>%
  mutate(week = floor_date(DatetimeUTC,"weeks")) %>%
  group_by(week,Frucht) %>%
  summarise(n = n()) %>%
  filter(!Frucht %in% frucht_remove) %>%
  filter(Frucht != "NA") %>%
  ggplot(aes(week,n, group = Frucht)) + 
  geom_line() +
  labs(x = "Time",y = "Number of Samples") +
  facet_wrap(~Frucht)





## Task 5 #######################

library(recurse)
library(ggforce)

recurs <- wildschwein_BE %>%
  filter(TierID == "001A") %>%
  dplyr::select(E,N,DatetimeUTC,TierID) %>%
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
wildschwein_BE %>%
  ungroup() %>%
  filter(TierID == "001A") %>%
  ggplot(aes(E,N)) +
  geom_point(alpha = 0.4, colour = "grey") +
  geom_circle(data = data1, alpha = 0.5, aes(x0 = x,y0 = y,fill = mean_time,r = 100),inherit.aes = F) +
  coord_fixed(1)

