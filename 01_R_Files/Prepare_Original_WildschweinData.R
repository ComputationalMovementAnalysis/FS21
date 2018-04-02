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

mcp <- wildschwein_sf2056 %>%
  group_by(TierID) %>%
  summarise() %>%
  st_convex_hull()

mcp95_centeroid <- mcp %>%
  st_centroid()

mcp95_centeroid <- mcp95_centeroid %>%
  st_coordinates() %>%
  as_tibble() %>%
  rename(E = X, N = Y) %>%
  bind_cols(mcp95_centeroid)

ggplot(mcp95_centeroid, aes(colour = TierID)) +geom_sf()

ug <- mcp95_centeroid %>%
  mutate(
    ug = ifelse(E>2610000,"AG","BE")
  ) %>%
  dplyr::select(TierID,ug)


wildschwein <- left_join(wildschwein,ug,by = "TierID")

tiere_BE <- wildschwein %>%
  filter(ug == "BE") %>%
  distinct(TierID) %>%
  pull()

tiere_AG <- wildschwein %>%
  filter(ug == "AG") %>%
  distinct(TierID) %>%
  pull()


wildschwein %>%
  filter(ug == "BE") %>%
  dplyr::select(-ug) %>%
  filter(TierID %in% tiere_BE[1:10]) %>%
  write_csv("../Geodata/wildschwein_BE.csv")


wildschwein %>%
  filter(ug == "AG") %>%
  dplyr::select(-ug) %>%
  filter(TierID %in% tiere_AG[1:10]) %>%
  write_csv("../Geodata/wildschwein_AG.csv")



write_csv(filter(wildschwein_AG,TierID %in% unique(wildschwein_AG$TierID)[1:3]), "../Geodata/wildschwein_AG.csv")
