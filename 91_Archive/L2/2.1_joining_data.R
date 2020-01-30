#############################################################################
## Joining data #############################################################
#############################################################################

# We have a table with additional data about our animals. If we want to add
# this data (e.g. sex and weight) to our data.frame automatically, we need to 
# join the data by a common variable, e.g., the animals' ID. 

# But first, import the data with the roe deer information into the project 
# "Rawdata_import.R" using the following command:
# roe_meta <- read.delim("Rawdata/Roe_meta.csv", header = T, sep = ";")

# There are several ways to join columns using base-R functions. We will, however, 
# use a function provided by the package dplyr, since we will be using this 
# package for a lot of tasks during the course. Import the dplyr library into your 
# project now.

# We want to add all values from the table "roe_meta.csv" (stored in the variable 
# "roe_meta") to the data.frame "gps_roe_all" via the animal ID. Note that 
# the column-names are different for the two ID columns ("TierID" and "ID").

gps_roe_all <- left_join(gps_roe_all, roe_meta, by = c("TierID" = "ID"))

# You probably recieved an warning message from dplyr, saying that the joining factors
# have different factor levels. This is because our "roe_meta"-data has an animal ID
# which is not available in the gps_roe_all data (RE13). Since I want to ignore this
# animal in my join, I chose a "left join" operation.  If you are not familiar with 
# the different type of joins, study the following image:
# http://planspace.org/20150530-practical_mergic_at_odsc/img/dplyr_joins.png

head(gps_roe_all)






