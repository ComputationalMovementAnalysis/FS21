#############################################################################
## Handling Time/Date values ################################################
#############################################################################

# We can look at the format of our gps data by using the function str()
str(gps_roe_all)

# R made some assumptions about the data format of the individual columns
# (is this variable an integer? a numeric? a factor?), but
# usually you will need to specify them manually. We will now define the
# date/time values as date-time objects. Handling time and date is actually
# quite nifty in R. For further information, read Safi 1.4.2. 

# In order to work with time/date values, we need to do four things:
# 1) chose a time/date object-type (POSIXct or POSIXlt)
# 2) join time and date to one object
# 3) specify how our time/date values are formatted (eg "dd.mm.yy" or "yyyy-mm-dd")
# 4) specify in which timezone the data is recorded 

# This command combines all points 1 - 4
gps_roe_all$DateTime <- as.POSIXct( # 1)
  paste(gps_roe_all$LMT_Date,gps_roe_all$LMT_Time), # 2)
  format = "%d.%m.%Y %H:%M:%S", # 3)
  tz = "Africa/Algiers") # 4)

# Our timevalues are recorded in Central European Time (CET). The speciality is, that
# Daylight Saving Time (DST) is not respected, so the data was recorded in CET all year. 
# If we assign the timezone "CET", R will think that our Data DOES respect DST. In order to 
# bypass this problem we can assign the Timezone "Algiers". This country is in the Timezone
# CET, but does NOT respect DST.

# Lets look at our data again
head(gps_roe_all)

# Since we dont need the columns "LMT_Date" and "LMT_Time" for now, lets get rid of them:
gps_roe_all$LMT_Date <- NULL
gps_roe_all$LMT_Time <- NULL


# Lets say we want to filter our Data and only work with July 2014. This would be a way 
# to do this:

# First, assign your start and end date/time values:
from <- gps_roe_all$DateTime >= as.POSIXct("2014-07-01 00:00:00")
to <- gps_roe_all$DateTime <= as.POSIXct("2014-07-31 23:59:59")

# Next, only select columns that match BOTH criterias (larger than from and smaller than to)
gps_roe_all <- gps_roe_all[from & to,]

# If you want to select certain an individual roe deer, this would be a way to do this:
# select RE02 OR RE12 OR RE07 using |
gps_roe_all <- gps_roe_all[gps_roe_all$TierID == "RE02" | gps_roe_all$TierID == "RE12" | gps_roe_all$TierID == "RE07",]

