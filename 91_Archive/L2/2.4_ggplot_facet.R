#############################################################################
## Using facet grid with ggplot #############################################
#############################################################################


# We've been using the base-R "hist" function to visualise our data very quickly for
# verifying purposes. To make a nice diagram to publish somewhere, it's smarter to use
# ggplot which we already got to know. For example, let's make a boxplot of the different
# traveling speeds of our three animals.

# Before we start, let's fix an issue with our data. The "join" operation
# in the last lesson produced an error message because the factor levels of the two tables
# didn't match. If we look at the structure of our TierID column, we will see that our data
# was actually modified (as the error message told us then, but we chose to ignore)
str(gps_roe_grouped$TierID)

# ggplot can't deal with "character" as a grouping variable, so let's turn the column back 
# into a factor. 
gps_roe_grouped$TierID <- factor(gps_roe_grouped$TierID)

# Now we can create a boxplot, similiar to how we created the map in the last lesson:
ggplot(gps_roe_grouped, aes(TierID, speed)) +
  geom_boxplot() 

# Not much to see here. So let's see what happens if we view the different days of the
# week. For this we will need to add a column "weekday" to our data using the lubridate
# function wday()
gps_roe_grouped$weekday <- lubridate::wday(gps_roe_grouped$DateTime,label = T)


# Making subgroups with the variable "weekday" is done by adding a layer named "faced_grid()"
ggplot(gps_roe_grouped, aes(TierID, speed)) +
  geom_boxplot() +
  facet_grid(.~weekday)

# Now we can see a distinct rise in outliers on friday, and lower "speeds" on saturday. 
# If you dont like the fact that the week starts on sunday, you don't change this 
# in ggplot, but you change the factor levels:
levels(gps_roe_grouped$weekday)

# You can see that the first value is "sun". You can change the order like this:
# http://www.cookbook-r.com/Manipulating_data/Changing_the_order_of_levels_of_a_factor/
gps_roe_grouped$weekday <- factor(gps_roe_grouped$weekday, 
                                  c(levels(gps_roe_grouped$weekday)[2:7],levels(gps_roe_grouped$weekday)[1]))

# We could have done this writing the weekdays out, but that might lead to spelling mistakes:
# gps_roe_grouped$weekday <- factor(gps_roe_grouped$weekday, 
# c("Mon", "Tues", "Wed", "Thurs" "Fri", "Sat", "Sun" ))

# Note that the language in which your weekdays appear is dependent on settings in your 
# operating system, and hence may be different on your computer

# Plot your data again, and voila, the week starts on monday
ggplot(gps_roe_grouped, aes(TierID, speed)) +
  geom_boxplot() +
  facet_grid(.~weekday)
