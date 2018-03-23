#############################################################################
## Simple visualization with ggplot2 ########################################
#############################################################################

# There is a generic plot function within R that is relatively easy to use. The 
# possiblities with this plotting function are very limited, which is why we will
# dive straight into a more powerful too, ggplot. Import ggplot into the project
# now using "library(ggplot2)" and include this statement in the apropriate file.

# ggplot is very powerful, but it might take a while to get used to it. Basically you set 
# up the source data in a first command ("ggplot()) and define the aesthetic-values (aes())
# Then you can add "layers" with information on how the source data should be displayed.

# load our data (gps_roe_all) and define the aesthetics (aes) with the column  
# names (X, Y, TierID)
ggplot(gps_roe_all, aes(X, Y, colour = TierID)) + 
  geom_point() +
  coord_fixed(ratio = 1)

# Animal RE12 has two data points that are approximately 2 km south of the other data.
# Lets assume these are outliers and remove them. One way to do this is defining a
# southern limit

gps_roe_all <- gps_roe_all[gps_roe_all$Y > 236000,]

# Now redo the above plot and check if your outliers are gone
ggplot(gps_roe_all, aes(X, Y, colour = TierID)) +
  geom_point() +
  coord_fixed(ratio = 1)

# you can now save this plot using ggplot(). If you don't specify a folder, it will save
# the plot to your current working directory. I would recommend to set up a specific folder
# for all your plots and even differentiating between different plot types (graphs, maps..)
ggsave("Plot_maps/simple_ggplot.png", dpi = 300, width = 15, height = 15, units = "cm")



#############################################################################
## More complex visualisations with ggplot ##################################
#############################################################################

# In the previous plot, we assigned colours to the AnimalID. Instead, we could
# assign colour to the time of day the animal was at a specific point. 

# To to this, we use the package "lubridate" which you can now install and  
# add to the appropriate project-file.
# The command "hour()" retrieves the hour of the day from a Date/Time Value.
# We will use this command INSIDE ggplot instead of adding an additional
# column:
hour(gps_roe_all$DateTime)

# Let's filter our data to ONE Roe deer using this command inside ggplot:
gps_roe_all[gps_roe_all$TierID == "RE12",]

# lets look at just one animal to see where it spends its days and nights
ggplot(gps_roe_all[gps_roe_all$TierID == "RE12",], aes(X, Y, colour = hour(DateTime))) +
  # assign the colour scale so that low numbers and high numbers are blue, while midday is red
  scale_colour_gradient2(low = "blue", mid = "red", high = "blue",midpoint = 12) +
  geom_point() +
  coord_fixed(ratio = 1)

# Save your plot:
ggsave("Plot_maps/advanced_ggplot.png", dpi = 300, width = 15, height = 15, units = "cm")



#############################################################################
## Adding a Background Map with ggmap #######################################
#############################################################################

# We can add a background map from online data using the library "ggmap". Add 
# this package to your project now.

# There are several ways to specify the geographical extent of the map that we 
# want to download and add to our plot. One way is by defining a bounding box, 
# but this doesn't really work with google maps data. Let's use this method anyway 
# because it seems to be the most intiutive way. Othere ways are described here:
# https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/ggmap/ggmapCheatsheet.pdf
# We need to refer to the WSG84 Coordinates since the ggmap uses this CRS.
myLocation = c(
  min(gps_roe_all$Lon), 
  min(gps_roe_all$Lat),
  max(gps_roe_all$Lon), 
  max(gps_roe_all$Lat)
)


# Download and store imagedata to variable. Note we use OpenStreetMap (OSM) data
myMap <- get_map(location=myLocation,source="osm", color="bw", crop=FALSE)

# ggplot adds a lot of items to a plot by default. We can supress this additional data
# by adding a layer "theme()" and defining it to our needs.

# Plot map
ggmap(myMap) +
  geom_point(data = gps_roe_all, aes(Lon, Lat, colour = TierID)) +
  theme_bw()

ggsave("Plot_maps/plot_ggmap.png", dpi = 200, width = 20, height = 20, units = "cm")

