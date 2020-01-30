#############################################################################
## Read and clean GPS Data of Roe deer ######################################
#############################################################################

# This file will do some data filtering and tidying up. The R object Roe_gps_all
# features 11 variables. For the moment we will focus on a selection of those.
# Overwrite gps_roe_all and only keep variables (aka columns) "TierID", "LMT_Date",
# "LMT_Time", "DOP", "Latitude...." and "Longitude....".

# To verify if the data was imported correctly: 
head(gps_roe_all)


# If you have a csv with many columns, it is advisable to eliminate unnecessary
# columns in the beginning so its much easier to keep an overview. You can always
# change the script later to include more columns if necessary.
gps_roe_all <- gps_roe_all[,c("TierID", "LMT_Date", "LMT_Time", "DOP", "Latitude....", "Longitude....")]

# Lets look at our data again:
head(gps_roe_all)

# I find the four dots after Lat/Long irritating. Selecting a single column by 
# name and renaming it is surprisingly unintuitive in R. But here's a quick 
# and dirty way to do it:
colnames(gps_roe_all)[colnames(gps_roe_all) == "Latitude...."] <- "Lat"
colnames(gps_roe_all)[colnames(gps_roe_all) == "Longitude...."] <- "Lon"

head(gps_roe_all)

# It would be easier to select the column by index/number but that can 
# quickly lead to silly mistakes since the column order can change during a project.
# This is how you call a specific column name by index:
colnames(gps_roe_all)[5]

