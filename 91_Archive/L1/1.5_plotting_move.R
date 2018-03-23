#############################################################################
## Introduction to "move" ###################################################
#############################################################################

# Dataframe objects are a convenient way to store general data. Working with 
# movement data, we have a lot of specific requirements which are only
# partially covered with data.frame objects. It is sometimes more reasonable
# to use an object type specifically designed for movement data. One such an
# object is the type "move" from the library "move". Get a quick introduction 
# to movement realated requirements and the "move" library in Safi 1.4.3.
colnames(gps_roe_all)

# A "move" object can contain the data of one animal. In order to store data of
# multiple animals, we need to create a "moveStack" object. This can be done by 
# using the command "move()", and specifying the animalIDs. Use ?move to find out
# in which manner we need to specify our data.
?move

# The helpfile is telling us that we need to specify all relevant data: X and Y
# coordinates, timedata and animalID. We can now convert (sometimes called coercing) 
# our data.frame into a move-object and save in a new variable.
gps_roe_move <- move(x = gps_roe_all$X,
     y = gps_roe_all$Y,
     time = gps_roe_all$DateTime,
     animal = gps_roe_all$TierID,
     data = gps_roe_all[,c("Lat", "Lon","DOP")])

# What's still missing here is the coordinate reference system. Our data uses the 
# CRS CH1903 / LV03 / EPSG 21781. 
# http://spatialreference.org/ref/epsg/21781/

proj4string(gps_roe_move) <- "+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +k_0=1 +x_0=600000 +y_0=200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs" 


# We can create a basic plot using this very simple command:
plot(gps_roe_move)

# "move" will give us many functions to analyse movement data later on in this project
# as we will see later on.


