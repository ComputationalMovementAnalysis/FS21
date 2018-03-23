#############################################################################
## Calculate distance and speed using dplyr #################################
#############################################################################

# In the previous script, we used dplyr to summarise data form a large dataset
# into a very small one using "summarise()". We also used "mutate()" to add 
# columns to our dataset. We were limited to retrieving information on the 
# whole dataset per animal. Many questions we will have are related to the 
# relation between sucessive gps-points, i.e. to sucessive rows. dplyr can 
# handle this easily.

# Let's say we want to calculate the sampling interval between sucessive fixes.
# So we want dplyr to subtract DateTime value 2 from value 1, value 3 from 
# value 2 and so fourth. Like this:

# Value 2 - Value 1
# Value 3 - Value 2
# Value 4 - Value 3
# ...
# minuend - subtrahend

# From an R perspective, its much easier (and faster) to view this operation as
# the substraction of two vectors of the same length (one vector being the minuend,   
# one the subtrahend). The minuend vector LEADS by one value, which is handled in dplyr
# as follows:

gps_roe_grouped <- mutate(gps_roe_grouped, timediff = lead(DateTime) - DateTime)
# View(gps_roe_grouped)

# Subtracting two POSIXct objects returns objects of the class "difftime":
str(gps_roe_grouped$timediff)

# For our purposes, it will be easier to work with integers. So let's reformulate the
# dplyr command:

gps_roe_grouped <- mutate(gps_roe_grouped, timediff = as.integer(lead(DateTime) - DateTime))
str(gps_roe_grouped$timediff)


# We can now use the Eucledian distance function we customised to calculate 
# the Eucledian distance between the rows:

gps_roe_grouped <- mutate(gps_roe_grouped, steplength = euclid(lead(X), lead(Y), X, Y))


# let's again have a look at our steplengths using "hist"
hist(gps_roe_grouped$steplength)

# Most steps are between 0 and 50 meters, and all steps are less than 1000 meters.
# Now let's calculate the speed at which the roe deer travel between the gps-fixes.

# Now let's calculate the speeds of all steps. If you think about it, 
# we don't need dplyr for this step, since we're not calculating relations 
# between rows, but between the columns "timediff" and "steplength". Let's use
# dplyr anyway for the sake of practice. 

# But before we calculate the speed, let's settle on a unit. Our timediff is in minutes 
# and our steplength is in meters. Meters per minute doesn't make much sense since its 
# not DIN conform. Meter per second is probabbly more useful for our case, so we will
# have to multiply our timediff values by a factor 60. We have to keep in mind that our timediff
# column is still in minutes, changing that to seconds as well would make the column
# harder to read.

# View(gps_roe_grouped)

gps_roe_grouped <- mutate(gps_roe_grouped, speed = steplength/(timediff*60))

# let's inspect our data again using hist()
hist(gps_roe_grouped$speed)

# most of the data lies between 0 and 0.1 m/s. But there is not much else we can 
# take from this diagram. Let's take a closer look at the values 0 to 0.4 using xlim
hist(gps_roe_grouped$speed, xlim = c(0,0.4))

# You can specify the size of the bin-size by using "breaks" and defining a sequence "seq()"
# of numbers. Let's say we want a bin size of 0.01, we would go about this like this:
hist(gps_roe_grouped$speed, xlim = c(0,0.4), breaks = seq(0,1.5,0.01))

# highlight and press ctrl+enter (windows) to see what the seq function does
seq(0,1.2,0.01)

# It creates a sequence of number from 0 to 1.2 with a spacing of 0.01. If you recieve
# an error message when defining the breaks, it is usually because your max value is
# not within the sequance you defined. Raise the second value in the seq() to solve the
# issue.

# If you want to take a closer look at your "rare" values (e.g. speed of 1.2 m/s) you
# can change the ylim rescaling the diagram. xlim and ylim can of course be combined.
hist(gps_roe_grouped$speed, breaks = seq(0,1.3,0.01), ylim = c(0,50))


