#############################################################################
## Multiscale analysis ######################################################
#############################################################################

# As Safi states in Chapter 3.3.2, traveling speed is highly susceptible to 
# scaling effects, and we have to be aware of the scaling issues that irregular 
# sampling could have on speed.

# Our roe deer data was sampled at two different sampling intervals: 3 hours
# and 5 minutes. In this excercise, we want to compare the speeds that we 
# can derive from these sampling intervals.

# First, let's have a look our sampling intervals again:
hist(gps_roe_grouped$timediff, breaks = seq(0,400,10)) # all of'em 
hist(gps_roe_grouped$timediff, breaks = seq(0,400,1), xlim = c(0,10)) # the small intervals, by minute
hist(gps_roe_grouped$timediff, breaks = seq(0,400,1), xlim = c(170,190)) # the large intervals, by minute

# Most values are around 5 and 180 minutes. But the time intervals vary. So let's make groups
# by rounding all values to the nearest 5 minutes. 
gps_roe_grouped$sampInt <- round(gps_roe_grouped$timediff/5,0)*5

# We can now create a boxplot using the rounded values as groups. I will use 
# the function "filter" dplyr) to select only only the finite values of 
# our sampInt column (last gps fixpoint of every roe deer does not have a time 
# differece therefore no sampInt-value). I will use a logarithmic y-axis so 
# that I can see all values.

# Note that I need to use the function "factor()" on our sampInt column since 
# ggplot cannot handle numeric data as a grouping interval for boxplots.

ggplot(filter(gps_roe_grouped, is.finite(sampInt)), 
       aes(factor(sampInt), speed)) +
  geom_boxplot() +
  scale_y_log10() +
  annotation_logticks(sides = "l") +
  labs(y = "speed (m/s)") 

# Since we only have a substantial amount of data for 5 minute and 180 minute 
# intervals, it would be reasonable to plot only the values with a sampInt 
# value of 5/180.

# We won't be needing the "sampInt" column for a while now, so let's get rid of
# it:
gps_roe_grouped$sampInt <- NULL
