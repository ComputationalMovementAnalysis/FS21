#############################################################################
## Import Rawdata ###########################################################
#############################################################################

#############################################################################
## Lesson 1 #################################################################
#############################################################################

# There are several ways to import CSV files. This is one of them:
gps_roe_all <- read.delim("Rawdata/Roe_gps_all.csv", sep = ",", header = T)
# Note that you can specify whether the data has a title (header) and what symbol
# is used to seperate the values (in this case a comma ",")

# To verify if the data was imported correctly: 
head(gps_roe_all)


#############################################################################
## Lesson 2 #################################################################
#############################################################################

# To import the Metadata of the roe deer, use:
roe_meta <- read.delim("Rawdata/Roe_meta.csv", header = T, sep = ",")

#############################################################################
## Lesson 3 #################################################################
#############################################################################



# Import Bike Data
gps_bike_all <- read.delim("Rawdata/gps_bike_all.csv", header = T, sep = ",")



