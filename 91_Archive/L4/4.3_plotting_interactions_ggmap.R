#############################################################################
## Plotting interactions with ggplot2 / ggmap ###############################
#############################################################################

# Now let's have a look at our deer-bike-interactions. Since We have have three-
# dimensional data (the 3rd dimension being "time") but only a 2D space to plot
# our data, we have to work with colours and only plot a small subset. 

# Now let's have a look at our deer-bike-interactions. If we
roe_bike_overlap_subset <- filter(roe_bike_overlap, TierID == "RE07", 
                                  as.Date(DateTime.roe) == "2014-07-14")

# Now let's download the background map for our data. Instead of downloading a new map
# for every subset (roe_bike_overlap_subset), we could also download the full map and then
# set the plot extents per subset individually. First, download the map using two coordinates
# (like we learnt in lessson "1.4_plotting_ggplot.R" we could also use a bounding box,
# but apperently this is a little glitchy for googlemaps data).

map <- get_map(location = c(lon = mean(roe_bike_overlap_subset$Lon.bike), lat = mean(roe_bike_overlap_subset$Lat.bike)), 
               zoom =  15, maptype = "terrain", source = "google", color = "bw")


# Now plot the data using ggmap
# X11()
ggmap(map, extent = "device")+
  geom_point(data = roe_bike_overlap_subset, 
             aes(Lon.bike,Lat.bike, fill = BikeDist_near_Gr), shape = 21, show.legend = TRUE) +
  geom_point(data = roe_bike_overlap_subset, 
             aes(Lon.roe,Lat.roe, fill = BikeDist_near_Gr), shape = 24, show.legend = TRUE) 




