#########################################################################
## Packages and Libraries for our Project ###############################
#########################################################################

# Importing all your packages in one place is a smart idea, and its even
# smarter to write a quick description on why you think you need that 
# specific package. Over time, the number of packages in a project can 
# grow and it can become confusing which packages does what. Functions of 
# different packages can "shadow" one another. This means that a funciton 
# call in one package is also used in a different package, usually the  
# output of the two function calls are very different.


#########################################################################
## Lesson 1 #############################################################
#########################################################################


source("WGS84_CH1903.R") # for converting position data from and to different CRS

library(ggplot2) # to create beautiful diagrams, maps, charts

library(lubridate) # to simplify working with date/time values

#library(move) # a package devoted to working with movement data 

library(ggmap) # to download and plot background maps for you ggplot map-plots


#########################################################################
## Lesson 2 #############################################################
#########################################################################

library(dplyr) # for SAC tasks

#########################################################################
## Lesson 3 #############################################################
#########################################################################

library(RcppRoll) # for moving window tasks
library(SimilarityMeasures) # to measure similarity of trajectories

#########################################################################
## Lesson 4 #############################################################
#########################################################################

library(leaflet)
library(data.table)

#########################################################################
## Lesson 5 #############################################################
#########################################################################

library(maptools)
library(rasterVis)
library(tidyr)

