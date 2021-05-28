crop_fanel <- read_sf("00_Rawdata/Feldaufnahmen_Fanel.gpkg")

head(crop_fanel)

summary(crop_fanel)

unique(crop_fanel$Frucht)

st_crs(crop_fanel)

ggplot(crop_fanel) +
  geom_sf(aes(fill = Frucht))
