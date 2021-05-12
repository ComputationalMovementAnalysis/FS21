
library(tidyverse)
library(sf)
library(stringr)
library(tmap)

################################################################################
## Prepare Wildboar data #######################################################
################################################################################


wildschwein <- read_delim("../../CMA_FS2018_Filestorage/wildschwein.csv",";",col_types = cols(timelag = col_double()))

# mit diesem Halsband (091) wurde rumgespielt (vermutlich transportiert und nochmal verwendet)
wildschwein <- filter(wildschwein, Tier != "091_Marg_12272")

# der letzte underscore in 083_Evel_12842_ stoert das separieren in seperate() unten
wildschwein$Tier[wildschwein$Tier == "083_Evel_12842_"] <- "083_Evel_12842"

wildschwein <- wildschwein %>%
  rowid_to_column("fixNr") %>%
  rename(DatetimeUTC = ZeitpUTC) %>%
  dplyr::select(Tier,DatetimeUTC,Lat,Long) %>%
  filter(!is.na(Lat)) %>%
  separate(Tier,into = c("TierID","TierName","CollarID")) %>%
  group_by(TierID) %>%
  mutate(CollarIDfac = LETTERS[as.integer(factor(CollarID))]) %>%
  ungroup() %>%
  mutate(TierID = paste0(TierID,CollarIDfac)) %>%
  dplyr::select(-CollarIDfac)


wildschwein_sf <-  st_as_sf(wildschwein, coords = c("Long", "Lat"), crs = 4326, agr = "constant")
wildschwein_sf <- st_transform(wildschwein_sf, 2056)

mcp_centeroid <- wildschwein_sf %>%
  group_by(TierID) %>%
  summarise() %>%
  st_convex_hull() %>%
  st_centroid()

mcp_centeroid <- mcp_centeroid %>%
  st_coordinates() %>%
  as_tibble() %>%
  rename(E = X, N = Y) %>%
  bind_cols(mcp_centeroid)

ggplot(mcp_centeroid, aes(colour = TierID)) +geom_sf() + coord_sf(datum = 2056)

ug <- mcp_centeroid %>%
  mutate(
    ug = ifelse(E<2610000,"BE",ifelse(E<2700000,"AG",NA))
  ) %>%
  dplyr::select(TierID,ug)


wildschwein <- left_join(wildschwein,ug,by = "TierID")




tiere_BE <- ug %>%
  filter(ug == "BE") %>%
  distinct(TierID) %>%
  pull()

tiere_AG <- ug %>%
  filter(ug == "AG") %>%
  distinct(TierID) %>%
  pull()


wildschwein %>%
  filter(ug == "BE") %>%
  dplyr::select(-ug) %>%
  filter(TierID %in% tiere_BE[1:10]) %>%
  write_csv("../CMA_FS2018_Filestorage/wildschwein_BE_all_raw.csv")




## Store a sample of values to csv

wildschwein %>%
  filter(ug == "AG") %>%
  dplyr::select(-ug) %>%
  filter(TierID %in% tiere_AG[1:10]) %>%
  write_csv("../Geodata/wildschwein_AG.csv")



wildschwein_AG <- wildschwein %>%
  filter(ug == "AG") %>%
  dplyr::select(-ug) %>%
  filter(TierID %in% tiere_AG[1:10])




## Store ALL values to CSV


wildschwein %>%
  filter(ug == "BE") %>%
  dplyr::select(-ug) %>%
  filter(TierID %in% tiere_BE) %>%
  write_csv("../CMA_FS2018_Filestorage//wildschwein_BE_all.csv")

wildschwein %>%
  filter(ug == "AG") %>%
  dplyr::select(-ug) %>%
  filter(TierID %in% tiere_AG) %>%
  write_csv("../CMA_FS2018_Filestorage/wildschwein_AG_all.csv")



################################################################################
## Prepare Crop data
################################################################################


fanel2016 <- read_sf("00_Rawdata/Feldaufnahmen_Fanel_2016.shp") %>%
  st_transform(2056)

fanel2016 <- fanel2016 %>%
  st_cast("POLYGON") %>%
  mutate(id = row_number())

fanel2016 <- fanel2016 %>%
  mutate(wald = Near_Wald == 0 & Frucht == 0 & !(id %in% c(104,131,174, 276, 415,417,435, 438, 439, 450, 867)))

fanel2016 <- fanel2016 %>%
  mutate(
    Frucht = ifelse(wald, "Wald",Frucht),
    Frucht = na_if(Frucht, 0)
  )


fanel2016 <- fanel2016 %>%
  mutate(
    Frucht = ifelse(id %in% c(437, 438, 441, 450) & is.na(Frucht), "Feuchtgebiet",Frucht)
  )

fanel2016 %>%
  select(FieldID, Frucht) %>%
  st_write("00_Rawdata/Feldaufnahmen_Fanel.gpkg",append = FALSE)


################################################################################
## Prepare LFI data
################################################################################

library(terra)
library(tmap)
lfi <- rast("00_Rawdata/vegetationshoehe_LFI.tif")
lfi

tm_shape(lfi) + tm_raster(palette = "viridis",style = "cont") 

