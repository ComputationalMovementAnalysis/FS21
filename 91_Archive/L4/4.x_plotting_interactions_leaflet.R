#############################################################################
## Creating a interactive map with leaflet ##################################
#############################################################################

# You've got to know two methods to plot your gps data: base-R plotting function
# which is quick, simple but not very pretty. ggplot2 which is a bit more
# script-work, but very sophisticated. One of your collegues (thank you Luca!) 
# made us aware of a third method: leaflet. It seems to be a very powerful
# tool specifically desinged for spatial data (base-R plot and ggplot2 are not!)$

# It brings R a very big step closer to a GIS, because it allows you to dynamically 
# explore your data. It can do much more though, especially for users who know 
# javascript and/or are interested to create (web-)applications. But in our course, 
# we will only cover the basics of leaflet. Install and load leaflet into your 
# project now.


# Like with dplyr, it makes a lot of sense to use the magrittr pipe command entry (%>%).
# Using %>% makes the set up a bit like ggplot2:

# start a leaflet map
leaflet(roe_bike_overlap) %>%
  # add gps points as circles and define your lat/lng coordinates
  addCircles(lat = ~Lat.roe, lng = ~Lon.roe) %>%
  # add a background map
  addTiles() 
  
# If you want the roe deer to appear in different colours, you have to
# prepare a colour function beforehand like this:
TierID_pal <- colorFactor(c("red","green","blue"), gps_roe_grouped$TierID)

leaflet(roe_bike_overlap) %>%
  # add your colour function using "color =" and  ~
  addCircles(lat = ~Lat.roe, lng = ~Lon.roe, color = ~TierID_pal(TierID)) %>%
  addTiles() 


# You can now filter your data to one date and add the bike-data as well.
leaflet(filter(roe_bike_overlap, as.Date(DateTime.roe) == "2014-07-14")) %>%
  addCircles(lat = ~Lat.roe, lng = ~Lon.roe, color = ~TierID_pal(TierID)) %>%
  addCircles(lat = ~Lat.bike, lng = ~Lon.bike, color = "black") %>%
  addTiles() 

  
# There are heaps of additional options that you can add to your map: layer control, popup
# informaiton and loads more. There's and introduction to leaflet here:
# https://rstudio.github.io/leaflet/
# Plus, Luca Scherrer seems to be quite an expert with leaflet, as him if you want some 
# information on more advanced techniques!
