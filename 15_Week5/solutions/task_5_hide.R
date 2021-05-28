veg_height_df <- terra::extract(veg_height,st_coordinates(wildschwein_BE))


wildschwein_BE <- cbind(wildschwein_BE,veg_height_df)

wildschwein_BE
