#############################################################################
## Data Manipulation with data.tables #######################################
#############################################################################

# If you use data.table to bring roe deer and bike data together, you will first 
# deal with the temporal question. The function foverlaps() finds overlaps of 
# two data.tables while comparing each row of one data table with each row 
# of the other.
  
# Our roe deer data has a sampling interval of 5 minutes, the bike data an interval of 
# 5 seconds. We will define an interval around each roe deer fix large enough to ensure
# that a bike-fix lays in that time interval. But first, we need to prepare our data.

# Create data.tables from data.frames
gps_roe_5min_dt <- as.data.table(gps_roe_grouped) %>%     # use magrittr's pipe function to...
  filter(!is.na(seq5min)) %>%                             # ...filter the 5min sequences
  dplyr::select(TierID, DateTime, X, Y,Lat,Lon) %>%       # ...and select only some columns
  rename(DateTime.roe = DateTime) %>%                     # ...and since we'll be joining the two data.tables, 
  rename(X.roe = X,Y.roe = Y,Lat.roe = Lat,Lon.roe = Lon) # let's rename the duplicate columns to avoid confusion
         
         
                                        


gps_bike_dt <- as.data.table(gps_bike_all) %>%              # do a similar operation for bikedata
  dplyr::select(ID, DateTime, X,Y,Latitude,Longitude) %>%   # i'm specifying the package in the "select()"
  rename(DateTime.bike = DateTime, X.bike = X,              # function (dplyr::) because the name "select"
         Y.bike = Y,Lat.bike = Latitude,                    # is also used by another package in my project
         Lon.bike = Longitude)                              # (aka "masking" or "shadowing")


# define a time-window around the roe deer fixes
gps_roe_5min_dt$GPSWindowMin <- gps_roe_5min_dt$DateTime.roe - 60
gps_roe_5min_dt$GPSWindowMax <- gps_roe_5min_dt$DateTime.roe + 60

# foverlaps needs TWO intervals. We only want to define ONE interval (for the roe deer data)
# and look at the bike fixes as specific points in time. In order to satisfy the foverlaps()
# demand, we can just duplicate our DatTime column to create an interval of length 0
gps_bike_dt$DateTime.bike2 <- gps_bike_dt$DateTime.bike

# In order to run foverlaps, our data.table need to be "keyed." The last two keys defined in
# setkey() are used to findoverlaps. 
setkey(gps_roe_5min_dt,GPSWindowMin,GPSWindowMax)
setkey(gps_bike_dt,DateTime.bike,DateTime.bike2)
# NOTE: keys play an important role in data.table and is one of the reasons why the 
# package is so fast. Data.table will now sort our data in the order in which we defined 
# our setkey(), similar to dplyr's arrange() command. Plus, setting keys is something like 
# group_by() in dplyr, datatable recognises unique keys as groups. We are wrongfully omitting
# the ID information in the above to setkey() statments. But we need to do this for foverlaps(),
# since the function would try and match the Roe Deer ID with the Bike ID if we'd pass on these
# keys to setkey(). We can undo this "mistake" after we've run the foverlaps function.

# Run the foverlap function. Option "mult" specifies what should happen if multiple values
# of table y fall into the interval of table x. mult = "all" will return all values of y, 
# duplicating the respecting row in x. "nomatch" specifies what should happen if a row in 
# y doesn't find a match in x. nomatch = 0 will ignore that row in y.
roe_bike_overlap <- foverlaps(gps_roe_5min_dt,gps_bike_dt,mult = "all",nomatch = 0)

# Let's delete the unnecessery columns to get a better overview of our data.
roe_bike_overlap$GPSWindowMin <- NULL
roe_bike_overlap$GPSWindowMax <- NULL
roe_bike_overlap$DateTime.bike2 <- NULL

# foverlaps messed up the order of our gps data. Setting the correct keys for our new
# data.table sorts the table automatically. 
setkey(roe_bike_overlap,ID,TierID,DateTime.bike)

# Let's also set the keys of our seperate bike and roe deer data.
setkey(gps_roe_5min_dt,TierID,DateTime.roe)
setkey(gps_bike_dt,ID, DateTime.bike)


# Now we can tackle the spatial issue: Find the distance between the mached GPS points 
# using our function "euclid()". 
roe_bike_overlap <- mutate(roe_bike_overlap,
                           BikeDist = euclid(X.roe,Y.roe,X.bike,Y.bike),
                           BikeDist_near = BikeDist < 250
                           )

# You can now group occurrences where deer and bikes approach each other with a unique ID using
# the number_groups function
roe_bike_overlap$BikeDist_near_Gr <- number_groups(roe_bike_overlap$BikeDist_near, F)

# We are only interested where the bikes actually approached the roe deer. Filter this data
# using a threshold: 
roe_bike_overlap <- filter(roe_bike_overlap, !is.na(BikeDist_near_Gr))





