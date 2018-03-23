#############################################################################
## Similarity Measures ######################################################
#############################################################################

# To test the reaction of the roe deer to mountainbikers, some reaction studies
# were conducted. Two or three bikers rode a predefined route in the vicinity 
# of collared roe deer. During that time the sampling interval between gps
# fixes was lowered to 5 minutes.

# Import the bike data to the project in the same way you imported the roe 
# deer GPS data (in Rawdata_import.R").

# Create POSIXct Column and specify the TimeZone the data was collected in
# NOTE: The Bikedata was collected in UTC! 
gps_bike_all$DateTime <- as.POSIXct(paste(gps_bike_all$Date,gps_bike_all$Time), 
                                    format = "%d.%m.%Y %H:%M:%S",tz = "UTC")
# Convert the TimeDate values into the timezone we are using in the project
attr(gps_bike_all$DateTime, "tzone") <- "Africa/Algiers"

gps_bike_all$Date <- NULL
gps_bike_all$Time <- NULL
gps_bike_all$Quality <- NULL
gps_bike_all$NumSat <- NULL
gps_bike_all$File <- NULL

# Create X/Y GPS Positions from WSG84
gps_bike_all$X <- WGS.to.CH.y(gps_bike_all$Lat, gps_bike_all$Lon)
gps_bike_all$Y <- WGS.to.CH.x(gps_bike_all$Lat, gps_bike_all$Lon)

# convert the ID column to a factor
gps_bike_all$ID <- as.factor(gps_bike_all$ID)

# Let's have a look at our different bike trajectories using ggplot.
ggplot(filter(gps_bike_all, as.numeric(ID) <= 3), aes(X,Y, colour = ID)) +
  geom_point() +
  coord_fixed(ratio = 1)

# 
# # As we can see, some trajectories are from bikers riding together, others
# # are individual bikers. We could group the bikers visually, but there are
# # also computational means to do this. Similarities between trajectories 
# # can be described using different measures. The R-package 
# # "SimilarityMeasures" provides several functions to automatically compute
# # these measures. Install the package and load it into your project now.
# 
# # We'll be using the Dynamic Time Warping Algorithm (DTW) function in this
# # example, mainly because it computates the index very fast. If you have 
# # a look at the function (using ?DTW) you will see that the input format
# # needs to be as a matrix.
# ?DTW
# 
# # To compare the Trajectories 1, 2 and 3 we will need to 
traj1 <-                       # a) create a new variable
  as.matrix(                   # b) convert the data into a matrix
  dplyr::select(               # c) select our relevant columns (X and Y)
    filter(                    # d) filter the data to the according ID
      gps_bike_all, ID == "1"),X,Y))
# View(traj1)


traj2 <- as.matrix(dplyr::select(filter(gps_bike_all, ID == "2"),X,Y))
traj3 <- as.matrix(dplyr::select(filter(gps_bike_all, ID == "3"),X,Y))
# 
# 
# # We are one step before we can make different comparisons between our 
# # trajectories. Right now, they are to large (>1000 coordinates)  and 
# # the computation of would take too long. So let's make a subset by
# # only selecting every 5th value using a logical vector
# sub <- c(TRUE,rep(FALSE,5))
# # View(sub)
# 
# traj1 <- traj1[sub,]
# traj2 <- traj2[sub,]
# traj3 <- traj3[sub,]
# 
# # Now we can use the DTW function to compare our three trajectories:
# DTW1_2 <- DTW(traj1,traj2)
# DTW1_3 <- DTW(traj1,traj3)
# DTW2_3 <- DTW(traj2,traj3)
# 
# 
# # Now we can use the LCSS function to compare our three trajectories:
# LCSS1_2 <- LCSS(traj1,traj2,2,5,0.5)
# LCSS1_3 <- LCSS(traj1,traj3,2,5,0.5)
# LCSS2_3 <- LCSS(traj2,traj3,2,5,0.5)
# 
# # Now we can use the EditDist function to compare our three trajectories:
# EditDist1_2 <- EditDist(traj1,traj2)
# EditDist1_3 <- EditDist(traj1,traj3)
# EditDist2_3 <- EditDist(traj2,traj3)
# 
# # Now we can use the Frechet function to compare our three trajectories:
# Frechet1_2 <- Frechet(traj1,traj2)
# Frechet1_3 <- Frechet(traj1,traj3)
# Frechet2_3 <- Frechet(traj2,traj3)
# 
# Check out the three trajectories and the computed similarities
ggplot() +
  geom_point(data = as.data.frame(traj1), aes(X,Y),col = "red") +
  geom_point(data = as.data.frame(traj2), aes(X,Y),col = "blue") +
  geom_point(data = as.data.frame(traj3), aes(X,Y),col = "green") +
  coord_fixed(ratio = 1)






