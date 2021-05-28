veg_height <- rast("00_Rawdata/vegetationshoehe_LFI.tif")


tm_shape(veg_height) + 
  tm_raster(palette = "viridis",style = "cont", legend.is.portrait = FALSE) +
  tm_layout(legend.outside = TRUE,legend.outside.position = "bottom", frame = FALSE)


