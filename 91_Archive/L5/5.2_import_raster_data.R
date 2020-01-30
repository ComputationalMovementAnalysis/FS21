#############################################################################
## Import and view raster data ##############################################
#############################################################################

# Importing rasterdata is pretty straightforward
alti3d <- raster::raster("Rawdata/SwissAlti3D/swissalti3d1/w001001.adf")

# explore your data with class, str etc
class(alti3d)
str(alti3d)
head(alti3d)


# It has a similar buildup like our vector data. You can check the CRS and set it if necessary 
alti3d@crs
alti3d@extent

crs(alti3d) <- EPSG_21781


# Viewing the data with base::plot is simple:
plot(alti3d)


