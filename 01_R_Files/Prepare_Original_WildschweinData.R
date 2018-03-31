devtools::install_git("https://github.engineering.zhaw.ch/PatternsTrendsEnvironmentalData/CMAtools.git")

library(tidyverse)
library(sf)
library(stringr)
library(CMAtools)
library(tmap)
str_remove_trailing <- function(string,trailing_char){
  ifelse(str_sub(string,-1,-1) == trailing_char,str_sub(string,1,-2),string)
}

wildschwein <- read_delim("../Geodata/wildschwein.csv",";",col_types = cols(timelag = col_double()))

wildschwein <- wildschwein %>%
  rowid_to_column("fixNr") %>%
  rename(DatetimeUTC = ZeitpUTC) %>%
  dplyr::select(Tier,DatetimeUTC,Lat,Long) %>%
  filter(!is.na(Lat)) %>%
  mutate(Tier = str_remove_trailing(Tier,"_")) %>%
  separate(Tier,into = c("TierID","TierName","CollarID")) %>%
  group_by(TierID) %>%
  mutate(CollarIDfac = LETTERS[as.integer(factor(CollarID))]) %>%
  ungroup() %>%
  mutate(TierID = paste0(TierID,CollarIDfac)) %>%
  dplyr::select(-CollarIDfac)

# mit diesem Halsband (091A) wurde rumgespielt (vermutlich transportiert und nochmal verwendet)
wildschwein <- filter(wildschwein, TierID != "091A")

wildschwein_sf = st_as_sf(wildschwein, coords = c("Long", "Lat"), crs = 4326, agr = "constant")
wildschwein_sf2056 <- st_transform(wildschwein_sf, 2056)


mcp95 <- mcp_sf(input = wildschwein_sf2056,TierID,percent =  95)

tmap_mode("view")

data("Europe")
tmap::tm_shape(Europe) +
  tmap::tm_polygons()

tm_shape(mcp95) +
  tm_polygons(col = "id")

mcp95_centeroid <- mcp95 %>%
  st_centroid()

mcp95_centeroid <- mcp95_centeroid %>%
  st_coordinates() %>%
  as_tibble() %>%
  rename(E = X, N = Y) %>%
  bind_cols(mcp95_centeroid)

ggplot(mcp95_centeroid, aes(colour = id)) +geom_sf()

ug <- mcp95_centeroid %>%
  mutate(
    ug = ifelse(E>2610000,"Aargau","Bern")
  ) %>%
  dplyr::select(id,ug)


wildschwein <- left_join(wildschwein,ug,by = c("TierID" = "id"))


wildschwein_BE <- wildschwein %>%
  filter(ug == "Bern") %>%
  dplyr::select(-ug)



wildschwein_AG <- wildschwein %>%
  filter(ug == "Aargau") %>%
  dplyr::select(-ug)


write_csv(filter(wildschwein_BE,TierID %in% unique(wildschwein_BE$TierID)[1:3]), "../Geodata/wildschwein_BE.csv")
write_csv(filter(wildschwein_AG,TierID %in% unique(wildschwein_AG$TierID)[1:3]), "../Geodata/wildschwein_AG.csv")
