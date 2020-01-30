
library(tidyverse)

wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE_all.csv",",")


wildschwein_BE %>%
  ggplot(aes(DatetimeUTC,TierID, colour = TierID)) +
  geom_point() +
  facet_wrap(~TierName, ncol = 1, scales = "free_y")

unique(wildschwein_BE$TierName)

wildschwein_BE <- wildschwein_BE %>%
  filter(TierName %in% c("Rosa","Ruth","Sabi"))


write_delim(wildschwein_BE,"00_Rawdata/wildschwein_BE.csv",",")



wildschwein_BE %>%
  mutate(timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")))%>%
  filter(timelag > 40, timelag < 70) %>%
  select(-timelag) %>%
  st_as_sf(coords = c("Long", "Lat"), crs = 4326) %>%
  st_transform(2056) %>%
  cbind(st_coordinates(.)) %>%
  rename(N = X, E = Y) %>%
  st_set_geometry(NULL) %>%
  head(200) %>%
  write_delim("00_Rawdata/caro60.csv",",")
  

  