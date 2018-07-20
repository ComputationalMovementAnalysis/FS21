#- header3 Preperation
#- chunkstart
## devtools::install_git("https://github.engineering.zhaw.ch/PatternsTrendsEnvironmentalData/CMAtools.git") # Reinstall this package, since we have a few updates
library(tidyverse)
library(CMAtools)
library(sf)
library(ggspatial)
library(raster)

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

#- chunkend
#- header3 Task 1
#- chunkstart

library(lubridate)

fanel2016 <- read_sf("../CMA_FS2018_Filestorage/Kulturen/Feldaufnahmen_Fanel_2016.shp") %>%
  st_transform(2056)

pk100_BE <- brick("../CMA_FS2018_Filestorage/pk100_BE_2056.tif")


wildschwein_BE_2016 <- wildschwein_BE %>%
  filter(DatetimeUTC >= as.Date("2016-04-01")) %>%
  filter(DatetimeUTC <= as.Date("2016-09-30"))


mcp2016 <- wildschwein_BE_2016 %>%
  group_by(TierID) %>%
  summarise() %>%
  st_convex_hull()


ggplot(fanel2016, aes(fill = Frucht)) + 
  annotation_spraster(pk100_BE) +
  geom_sf(alpha = 0.3) +
  geom_sf(data = mcp2016, aes(colour = TierID), inherit.aes = F, alpha = 0.1,lwd = 2) +
  theme(legend.position = "bottom")
  
#- chunkend
#- header3 Task 2
#- chunkstart
wildschwein_BE_2016 <- wildschwein_BE_2016 %>%
  st_join(dplyr::select(fanel2016,Frucht))


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
  facet_wrap(~Frucht) +
  theme_minimal()

#- chunkend
#- header3 Task 4
#- chunkstart
ndsm <- raster("../CMA_FS2018_Filestorage/nDSM.tif")

wildschwein_BE_2016 <- wildschwein_BE_2016 %>%
  mutate(dod = raster::extract(ndsm,.))


wildschwein_BE_2016 %>%
  as.data.frame() %>%
  mutate(
    hour = hour(round_date(DatetimeUTC,"1 hours"))
    ) %>%
  group_by(TierID,hour) %>%
  summarise(
    mean = mean(dod,na.rm = T),
    sd = sd(dod,na.rm = T),
    up = mean+sd,
    do = mean-sd
    ) %>%
  ggplot(aes(x = hour,y = mean,ymin = do, ymax = up, colour = TierID,fill = TierID)) +
  geom_ribbon(alpha = 0.4) +
  geom_line() +
  labs(x = "nDSM",title = "nDSM values as an approximation for vegitation hight",subtitle = "The line represents the mean nDSM value and the ribbon one standard deviation") +
  theme_minimal()
    
  

#- chunkend
