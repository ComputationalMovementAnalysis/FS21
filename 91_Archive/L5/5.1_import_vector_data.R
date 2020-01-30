#############################################################################
## Import and view vector data ##############################################
#############################################################################

# Frequently, when installing a certain packge, this package itself depends
# on other packages (so called package dependencies). RStudio installs these 
# packages automatically. 

# When installing the package "move", we've installed several important packages
# that help us now dealing with geodata, as shown in the messages after loading the
# library:
  # Lade noetiges Paket: sp
  # Lade noetiges Paket: raster
  # Lade noetiges Paket: rgdal
# We are going to need these packages for most of our operations that we'll do
# when working with the swisstopo geodata vec25 and DHM25. But in addition to these
# packages, we'll need "maptools".

# Note: if you get an error message that sounds something like this:
# Error in loadNamespace(name) : there is no package called "maptools"
# This just means that the installation of a dependent packge hadn't worked. 
# Just install and load the package that is mentioned in the error message 
# (in this case "maptools").

tlm_boden <- maptools::readShapePoly("Rawdata/SwissTLM3D/bodenbedeckung.shp")

# have a look at the class and structure of our shapefile
class(tlm_boden)
str(tlm_boden)
summary(tlm_boden)
?SpatialPolygonsDataFrame
?readShapePoly

# A SpatialPolygonsDataFrame consists of different "slots" that can be accessed 
# via the "@" sign.
# The slots are: 
  # data: the attribute table
  # polygons: the polygon coordinates
  # plotOrder: 
  # bbox: extent
  # proj4string: coordinate reference system

head(tlm_boden@data)
tlm_boden@bbox
tlm_boden@proj4string

# The data doesn't seem to have a CRS. Let's add CH1903. Since we'll use this 
# CRS often, it's practical to assign it to a variable.
EPSG_21781 <- CRS("+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +k_0=1 +x_0=600000 +y_0=200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs" )
crs(tlm_boden) <- EPSG_21781
# Note: CRS() creates a "CRS-Object", crs() is used to assign a coordante reference system (with <- )

# In order to visualise our data with ggplot, we will first need to convert it 
# into a normal dataframe. Read here more about this task:
# http://mazamascience.com/WorkingWithData/?p=1494)

# Add the rownames as a column:
tlm_boden@data$id <- rownames(tlm_boden@data)
# create a dataframe using ggplot's fortify() command:
tlm_boden_df <- fortify(tlm_boden, region = "id")
# join the data.frame and the attribute table
tlm_boden_df <- full_join(tlm_boden_df, tlm_boden@data, by = "id")
head(tlm_boden_df)

# Now our data ist ready for plotting:
ggplot() +  
  # Note: I'm using the command factor(OBJEKTART) so that ggplot views the code as discrete,
  # and not as a continuous variable. This just has an effect on the type of colorpalette
  # that ggplot automatically assigns.
  geom_polygon(data = tlm_boden_df, aes(long, lat, group = group, fill = factor(OBJEKTART))) +
  scale_fill_discrete() +
  coord_fixed(ratio = 1)

# If you want to find out what the codes for "OBJEKTART" mean, just check the documentation:
# http://www.swisstopo.admin.ch/internet/swisstopo/de/home/products/landscape/swissTLM3D.html
# http://www.swisstopo.admin.ch/internet/swisstopo/de/home/products/landscape/swissTLM3D.parsysrelated1.47641.downloadList.97108.DownloadFile.tmp/201603swisstlm3d14okd.pdf

# PS: if somebody takes the time to add some reasonable colours to the codes, I'm interested!



