
library(tidyverse)
library(sf)
library(stringr)
library(tmap)



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

tm_shape(lfi) + tm_raster(palette = "viridis",style = "cont") 
  
