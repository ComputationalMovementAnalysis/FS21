#############################################################################
## Calculate timelags using move ############################################
#############################################################################

# A while ago, we've talked about the package "move" and we did a first
# map plot using this package. But since then we've addressed all our movement 
# related tasks (steplength, timediff, speed) using dplyr. This was a very
# good excercise, since now you have tools to do all sorts of crazy things 
# with your data. 

# But now, let's take a look at our move package again and see what tools we have 
# there. We created a "moveStack" object a while ago, let's have a look at it again:
gps_roe_move

# Safi Chapter 3.2 shows us that calculating time differences between gps-fixes
# is achieved using this command:
timeLag(gps_roe_move, units = "mins")

# This command retrieves the timelags, but doesn't add it to our original data.
# Let's save the data to a variable and have a look at it:
timeLags <- timeLag(gps_roe_move, units = "mins")

# Lets look at the structure of the output:
str(timeLags)


# We can see that it's a list containing three numerical vectors. Let's have a closer
# look at this list-object

#############################################################################
## A quick look at "list"-objects ###########################################
#############################################################################

# A list is an object type (a collection) that can contain basically ANYTHING, even 
# dataframes or other lists. Read a quick introduction to lists 
# (and other data types in R) here:
# http://www.statmethods.net/input/datatypes.html

# Accessing the timelags of one animal is done like this:
timeLags[[1]] # by index (note the double brackets)
timeLags[["RE02"]] # or by name

# if you use double brackets, the structure of your output will correspond to the
# structure of the data that was added to the list. Earlier I wrote "timeLags" is a list 
# containing 3 numerical vectors. So using [[]] should output a numeric vector. 
# let's checK:
str(timeLags[[1]])

# if you add single brackets, the structure of your ouptut remains a list (which has
# some disadvantages)
str(timeLags[1])

# If you want, can access a specific value of a specific object in a list as follows:
timeLags[[1]][1]

# Using the function "unlist()" turns a list into a "named numeric vector". A named
# numeric vector is just like a normal numeric vector, but each value has a corresponding
# name. With a numeric vector, we can create something like a histogram (what we
# cannot do with a list)
str(unlist(timeLags))

# Let's make a side-by-side comparison via a histogram of the data we created 
# using the two methos:
hist(unlist(timeLags), main = "Histogram using MOVE-data")
dev.new() # opens a new plot window
hist(gps_roe_grouped$timediff, main = "Histogram using DPLYR-data")
# the histograms seem to be identical. Let's close the new plot widow again:
dev.off()

# Calculating the timeLags between n values returns n-1 values. dplyr solved
# this by using "NA" (not available) for the last value of every roe deer. 
tail(gps_roe_grouped$timediff) # tail shows the overall last values of the data.frame

# Let's compare the number of values between the two methods:
length(unlist(timeLags)) - length(gps_roe_grouped$timediff)

# Using the package move, we have 3 values less than using dplyr. This means every
# roe deer is missing one value (the last one). We need to keep this in mind when  
# working with "move".


#############################################################################
## Calculate distances, speed and turning angles using "move" ##############
#############################################################################

# In the same way we calculated the timelags, move allows us to calculate
# distance and speed between the gps points:
distances <- distance(gps_roe_move)
speeds <- speed(gps_roe_move)


# Move allows us to calculate these values with little effort. We were able to
# calculate them with dplyr as well, giving us the advantage of full control. 
# Move has some additional functions, that would be rather tricky to implement
# just with dplyr. One example is the function "angle()", which returns the
# turning angle (see Safi 3.3.3). Again, you need only one command:
angle <- angle(gps_roe_move)

hist(unlist(angle))

tail(angle)




