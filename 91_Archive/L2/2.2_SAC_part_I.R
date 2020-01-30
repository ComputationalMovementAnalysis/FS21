#############################################################################
## An introduction to SAC: Split-Apply-Combine ##############################
#############################################################################

# When working with data, many tasks involve splitting the data into different
# categories, proccessing these subcategories in a specific way, and then 
# re-combining the data. This is know as the SAC-paradigm
# (split-apply-combine).

# Base-R has some built-in functions to take care of SAC tasks. The dplyr package
# (which we got to know in the join operation) is much more powerful and we will 
# be using dplyr to address SAC tasks.

# The DOP Value in our gps data shows the dilution of precision, i.e. gives an  
# indication of how precise the gps-point was captured by the satellites. For more 
# information on DOP, check:
# https://en.wikipedia.org/wiki/Dilution_of_precision_%28GPS%29

# Let's say we want to get some information about the difference of DOP values
# between the different animals. We could use something like this:
mean(gps_roe_all$DOP[gps_roe_all$TierID == "RE02"])
# but that would be very tedious, especially if you have many different animals

# Instead, let's use dplyr. With dplyr, we will need to group our data first (the
# S in our SAC-paradigm). This is done like this:
gps_roe_grouped <- group_by(gps_roe_all, TierID)

colnames(gps_roe_grouped)
# Read more about group_by here:
# https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html

# next, you can start summarising. 
summarise(gps_roe_grouped, mean = mean(DOP), max = max(DOP), min = min(DOP))
# We took care of SPLITTING our data with the "group_by()" command. the functions
# "mean()", "max()" and "min()" are APPLIED to our SPLIT data and "summarise()"
# COMBINES our data again (SAC).

# The output is a short table summarising our original data. If you want to include
# the output data into the original table, you will have to use "mutate".
mutate(gps_roe_grouped, mean = mean(DOP))
# Note that we didn't assign the output of this function to a variable, so the result
# is just displayed in our console but not saved.

# With this function, we have a powerful tool to get various information on very 
# big datasets in a matter of seconds. But for now, we are limited to retrieving
# information on the whole dataset per animal (e.g. the mean DOP per roe deer).
# Many questions we will have are related to the relation between two sucessive 
# gps-points, i.e. to sucessive rows, or a moving temporal window. dplyr can handle 
# this easily, as we will see in the next script.
