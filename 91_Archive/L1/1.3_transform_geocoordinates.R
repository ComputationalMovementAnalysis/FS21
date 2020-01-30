#############################################################################
## Transforming Coordinates into Swiss Coordinate System ####################
#############################################################################

head(gps_roe_all)
# So at the moment, our GPS Data is in the WSG84 format. Let's transform these into 
# the swiss format and add the columns X and Y. Swisstopo provides a script with 
# various functions to do such transformations. It can be downloaded from here:
# http://www.swisstopo.admin.ch/internet/swisstopo/de/home/products/software/products/skripts.html

# Its reasonable to import all scripts and libraries in a central area in the beginning
# of your Master file. So do this now using "source()"

# using the function provided from swisstopo, we can transfrom the lat/lon coordinates to
# swiss coordinates. In the mathematical convention the x-value describe offset to the 
# east while the y-value describes an offset to the the north. It's geodetics practice 
# to use a "left handed" coordinate system where x and y are flipped. This swiss-topo 
# script uses a left handed coordinate system as well, but since we will use the  
# mathematical convention in this course, we will use the formula for x to calculate 
# the y value and vice versa.

gps_roe_all$X <- WGS.to.CH.y(gps_roe_all$Lat, gps_roe_all$Lon)
gps_roe_all$Y <- WGS.to.CH.x(gps_roe_all$Lat, gps_roe_all$Lon)

# View(gps_roe_all)
