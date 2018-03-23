#############################################################################
## Identifying and grouping 5-min intervals #################################
#############################################################################

# Let's have a look at the nature of the sampling intervals of our data. 
hist(gps_roe_grouped$timediff)

# We have two sampling interval values: The standard sampling intervals is  
# 180 min. On some days, the sampling interval is reduced to 5 minutes.  
# Since 180 is a multiple of 5, we can say that we have a continuous sampling 
# of 180 minute intervals and short, restricted sequences of 5 minute intervals
# (let's call these "seq5min").

# We can work better with our data if we identify our seq5min, i.e. segment our trajectory, and then
# lable the segments sequentially (i.e. number them successively). Identifying them is easy, we 
# just need our "timediff" column and a threshold. 
# Since we've seen that the time interval isn't exactly 5 minutes, let's have 
# a closer look at our data to find a reasonable threshold:
hist(gps_roe_grouped$timediff, breaks = seq(0,400,1), xlim = c(0,20), ylim = c(0,100))

# There seems to be a gap after about 7 minutes. If we take 10 minutes as a 
# threshold value to define a short sampling interval, all our short-interval 
# samples would be marked as such.
gps_roe_grouped$timediff_sm <- gps_roe_grouped$timediff < 10

# timediff_sm tells us if a gps-fix belongs to a 5 minute sampling period 
# (TRUE) or not (FALSE). What we need to do is define a variable to group 
# the individual 5min-sequences. 

# An example from our timediff_sm column could look like this: 
test <- c(T,T,T,F,F,T,T,T)
test
# This sequence would consist of two 5min-sequences (the first three and
# the last three). We need a function that gives the first three values 
# one label and the last three values another label. 

# Since I haven't found a function that will cover this task, I've 
# created a function myself. It would go beyond the scope of this course 
# to go into the details of the function. Just have a look at the function
# "number_groups" (Custom_Functions.R) and test it on our sample data.

number_groups(test,include_next = T)
number_groups(test,include_next = F)

# I've designed the function to optionally include the first FALSE value after
# a TRUE sequence into the preceeding TRUE-group. I've done this to meet the 
# requirements of our input data: The timediff/timediff_sm columns describe  
# the relationship between the current row and the proceeding. I won't explain 
# this further, have a look at our data (the "timediff_sm" column) and 
# if you would want to know more about this, just ask us in class.

# We can now use the function to label our 5min-sequnces. 
gps_roe_grouped$seq5min <- number_groups(gps_roe_grouped$timediff_sm, T)

# We will not need the column "timediff_sm" anymore. Let's remove it to keep our 
# dataset lean. Let's also remove our "test" variable
gps_roe_grouped$timediff_sm <- NULL
remove(test)


  
