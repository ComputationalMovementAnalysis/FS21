#############################################################################
## Identifying 180 min fixes ################################################
#############################################################################

# In the previous excercise, we've made groups of successive gps sampled in 
# a 5min interval. We concluded that we have a continuous sampling interval
# of 180 min interval, since 180 is a multiple of 5. Now that we've marked and 
# labeled our 5min intervals, let's mark our 180 minute fixes.

# In the previous excercise, we identified and grouped all values belonging to a
# 5-minute sequence. All values NOT belonging to a 5-minute sequance belong
# to the 180 minute sampling interval. Let's first mark those:
gps_roe_grouped$sampling_180 <- F
gps_roe_grouped$sampling_180[is.na(gps_roe_grouped$seq5min)] <- TRUE

# What we don't know at this point is whether the 180 minute sampling interval 
# is at fixed hours of the day, or whether they are relative to the previous
# fix and so subject to a time drift.

# Let's clarify this question right away. To do this, I will transform our DateTime 
# values into decimal hours and look at the frequency of sampling distribution. 
# I would expect distinct peaks if the sampling intervals were at fixed hours, 
# and a more uniform distribution if a timedrift was involved
gps_roe_grouped$hour_dec <- hour(gps_roe_grouped$DateTime) + minute(gps_roe_grouped$DateTime)/60 + second(gps_roe_grouped$DateTime)/3600
# this time I'll use the ggplot histogram so that I can split the data into individual animals
ggplot(gps_roe_grouped, aes(hour_dec)) +
  geom_histogram(binwidth = 0.1) + # a binwith of 0.1 now corresponds to 6 minutes
  scale_x_continuous(breaks = seq(0,24,1)) +
  facet_grid(TierID~.)

# Very clearly, the hours for the 180 sampling intervals are fixed, starting at midnight
# and then 3.00, 6.00 9.00 etc. In other words, the sampling hours are multiples of 3.
# We can now mark all gps fix that belong to the 180 sampling interval by finding the 
# closest fix to a multiple of 3.

# First, we need to determin the closest multiple of three. This can be done with the
# following steps:
# 1) devide the value by 3
# 2) round it to the the nearest whole number
# 3) multiply the value by 3

# Let's just create our own function to take care of this task. Copy the following 
# function to your Script "Custom_Functions.R" and import it into the project:

# round_multiple <- function(value,multiple){
#   round(value/multiple,0)*multiple
# }

# Test the function on the number 1 to 100
round_multiple(1:100,3)

# Note that we can't use this function on POSIXct objects. We need to use our "hour_dec"
# colummn (which provides the hour of the day in decimal units)
round_multiple(gps_roe_grouped$hour_dec,3)

# Now that we can calculate the nearest multiple of 3 of every time-value, we can easily
# calculate their differences. Since we care about absolute differences (we DONT care
# about + or -) we need to wrap our formula in an abs() function
gps_roe_grouped$proximity <- abs(gps_roe_grouped$hour_dec - round_multiple(gps_roe_grouped$hour_dec,3))

# Using the column "proximity", I can find out which time-values are close to a  of
# multiple 3 by defining a threshold. Let's define our threshold is 6 minutes, that would
# be 0.1 hours:
# View(gps_roe_grouped)

gps_roe_grouped$close <- gps_roe_grouped$proximity < 0.10

# We want to see how well our threshold fits our data, look at the data.frame
# View(gps_roe_grouped)

# We can see that all our fixes OUTSIDE of the 5-minute sequences are of course below
# the threshold. We don't need those values since we marked them already at the beginning
# of this script. We can remove them from our variable using a condition

gps_roe_grouped$close[gps_roe_grouped$sampling_180 == T] <- FALSE
# View(gps_roe_grouped)

# We can now see that our threshold included multiple values of the 5-min sequance. We
# have to choose ONE value from each group. Again, I've created a custom function that
# determins wheter a number is a local minimum or not. It's very basic and can't handle 
# many special cases. But for our application, it will be good enough. Copy and import the
# following function to your project:

# local_min <- function(values){
#   diffs <- head(values,-1) - tail(values,-1)
#   return(c(diffs < 0,T) & c(T,diffs > 0))
# }

# Test it
local_min(c(3,3,2,3,4,2))

gps_roe_grouped$sampling_180[gps_roe_grouped$close] <- local_min(gps_roe_grouped$proximity[gps_roe_grouped$close])

# View(gps_roe_grouped)

# lets remove all the rows we will probabbly not need again
gps_roe_grouped$hour_dec <- NULL
gps_roe_grouped$proximity <- NULL
gps_roe_grouped$close <- NULL
gps_roe_grouped$hour_dec <- NULL
colnames(gps_roe_grouped)