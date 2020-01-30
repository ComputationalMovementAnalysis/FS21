#############################################################################
## Moving window ############################################################
#############################################################################

# We used a moving window in "L3/3.2_stop_and_moves.R" to find out whether
# the animals are stopping or moving. Since we used the formula provided by
# Laube & Purves (2011), we couldn't use a predefined moving window function.
# But you will need "classic" moving window functions often when working
# with movement data, let's have a look at them as well. 

# Consider a situation where you'd want to calculate the avarage speed over 
# three positions per roe deer. To do this, we need to calculate the mean over 
# two values of the column "speed". Each value will be used twice (with the
# exception of the first and last value).

# The library "RcppRoll" provides a set of useful "moving window" functions.
# Install and import this library to your project now.

# let's try it out on some sample data.
?roll_mean

roll_mean(1:10, n = 2) # mean over two values on the number 1 to 10
roll_mean(1:10, n = 4) # mean over four values

# RcppRoll works very intuitively. You might have noticed that the resulting
# vector is shorter than the input vector. With "n" values and a moving window "v",  
# the resulting output of any moving window analysis has a length of n - v + 1.

# But if you want to add the resulting data as a column to the original data, it 
# is more practical if the output vector has the same length as the input vector. 
# Using "lag()" in  the "mutate" function from "dplyr", the last value was filled 
# with "NA". The same can be achieved with roll_mean() using the option "fill".
roll_mean(1:10, n = 2, fill = NA)
roll_mean(1:10, n = 4, fill = NA)

# You can further align your data to one side, 
roll_mean(1:10, n = 2, fill = NA, align = "left") # equals to "top" in a data.frame
roll_mean(1:10, n = 2, fill = NA, align = "right") # equals to "bottom" in a data.frame
roll_mean(1:10, n = 2, fill = NA, align = "center") # default


# We can now combine dplyr and RcppRoll. All we need to do is use the fill option and 
# decide on an alignment. I like to use "left", so the data is "top aligned" this
# simplyfies data handling.
gps_roe_grouped <- gps_roe_grouped %>%
  group_by(TierID) %>%
  mutate(
    speed_mw = roll_mean(speed, n = 2, align = "center", fill = NA)
    )

View(gps_roe_grouped)
tail(gps_roe_grouped$speed_mw) # Note the two "NA“ at the tail.

# We now know how to move a windows of a specific size over our data whilst respecting
# the individual roe deer. What we have not considered yet is the fact that our sampling
# interval varies between 5 and 180 minutes. Now our seq5min column comes in handy. We can
# use this column to further group our data with "group_by", like we did with the roe
# deer ID. We can group our data with the variable seq5min:


# X11()
gps_roe_grouped <- gps_roe_grouped %>%
  group_by(TierID,seq5min) %>% 
  # we need to re-state that we want to group it with TierID
  mutate(speed_mw = roll_sum(speed_mw, n = 4, align = "left", fill = NA))
  # remember that your new grouping variables are stored in gps_roe_grouped. If you 
  # don't want to consider "seq5min" as a grouping variable in further mutate 
  # or summarise operations, you will need to re-specify the grouping variables
  # in your next operation. I would recommend to specify your grouping variables
  # in EVERY dplyr-mutate/summarise operation.


# Dplyr viewed NA values in the "seq5min" column as an own group. This leads to unusable
# results. We could delete the data where "seq5min" is NA, or we could prevent dplyr to
# calculate results for NA values beforehand using an ifelse() function:
gps_roe_grouped <- gps_roe_grouped %>%
  group_by(TierID,seq5min) %>%
  mutate(speed_mw = ifelse(is.na(seq5min), as.numeric(NA), roll_sum(speed, n = 4, align = "left", fill = NA)))

  
View(gps_roe_grouped)

