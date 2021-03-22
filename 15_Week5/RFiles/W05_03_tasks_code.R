## Task 1 ######################################################################


library(lubridate)
library(tmap)

fanel2016 <- read_sf("00_Rawdata/Feldaufnahmen_Fanel_2016.shp") %>%
  st_transform(2056)



max(wildschwein_BE$DatetimeUTC)


wildschwein_BE_2015 <- wildschwein_BE %>%
  filter(DatetimeUTC > "2015-01-05",DatetimeUTC < "2015-07-31")

mcp2015 <- wildschwein_BE_2015 %>%
  group_by(TierID) %>%
  summarise() %>%
  st_convex_hull()


tm_shape(fanel2016) + 
  tm_polygons(col = "Frucht") +
  tm_shape(mcp2015) +
  tm_borders(lwd = 3,lty = 2)


#- chunkend

## Task 2 ######################################################################

wildschwein_BE_2015 <- wildschwein_BE_2015 %>%
  st_join(dplyr::select(fanel2016,Frucht))


wildschwein_BE_2015 %>%
  st_set_geometry(NULL) %>%
  mutate(week = floor_date(DatetimeUTC,"weeks")) %>%
  group_by(TierID,week,Frucht) %>%
  summarise(n = n()) %>%
  filter(!Frucht %in% c("0","Flugplatz","Rhabarber","Zucchetti","NA")) %>%
  ggplot(aes(week,n, colour = TierID)) + 
  geom_line() +
  labs(x = "Time",y = "Number of Samples") +
  facet_wrap(~Frucht) +
  theme_minimal()


## Task 4 ######################################################################

vegetation_height <- raster("00_Rawdata/vegetationshoehe_LFI.tif")

wildschwein_BE_2015 <- wildschwein_BE_2015 %>%
  mutate(dod = raster::extract(vegetation_height,.))


wildschwein_BE_2015 %>%
  st_set_geometry(NULL) %>%
  mutate(
    hour = hour(round_date(DatetimeUTC,"1 hours"))
    ) %>%
  group_by(TierID,hour) %>%
  summarise(
    mean = mean(dod,na.rm = T),
    ) %>%
  ggplot(aes(x = hour,y = mean,colour = TierID)) +
  geom_line() +
  labs(
    x = "Hour",
    y = "Vegetation Height (Meters)",
    title = "Mean Vegetation Height per hour"
    )+
  theme_minimal()
    
