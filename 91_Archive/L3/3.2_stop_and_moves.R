#############################################################################
## Stops and Moves #############################################################
#############################################################################

# We want to find out if an animal is moving or resting. The simplest way to do  
# this would be to calculate the distance or traveling speed between two points  
# and define a threshold and based on gps accuracy to decide whether an animal 
# is moving or not. 

# Laube & Purves (2011) define "static" fixes as "those whose average Euclidean 
# distance to other fixes inside a temporal window v is less than some 
# threshold d".

# Let's create this on our some dummy coordinates and work with them for now.
# X <- abs(rnorm(10))
# Y <- abs(rnorm(10))

X <- cumsum(1:10)
Y <- cumsum(1:10)

# We'll assume they have a sampling interval of 5 minutes. If we take a temporal 
# window of 20 minutes, that would mean we include 5 fixes into the calculation. 
# We need to calculate the following Eucledian distances (pos representing a 
# X,Y-position):

# 1) pos[n-2] to pos[n] 
# 2) pos[n-1] to pos[n]
# 3) pos[n] to pos[n+1]
# 4) pos[n] to pos[n+2]

# We can use the custom function "euclid()" to calculate the distances 
# and dplyr functions lead/lag to create the necessary offsets.
before_last_pos <- euclid(lag(X, 2),lag(Y, 2),X,Y)   # 1)
last_pos <- euclid(lag(X, 1),lag(Y, 1),X,Y)   # 2)
next_pos <- euclid(X,Y,lead(X, 1),lead(Y, 1)) # 3)
after_next_pos <- euclid(X,Y,lead(X, 2),lead(Y, 2)) # 4)

# We now want to find out the mean PER ROW. The follwing gives us the overall mean:
mean(c(before_last_pos,last_pos,next_pos,after_next_pos), na.rm = T) 
# To retrive the mean per row, we can do this:
rowMeans <- rowMeans(
  cbind(before_last_pos,last_pos,next_pos,after_next_pos) # binds the vectors as columns as a matrix
)

# View(rowMeans)
remove(rowMeans)

# We can now combine the above code with a mutate funtion and thus append the rowMean values 
# to our roe deer data:
gps_roe_grouped <- mutate(gps_roe_grouped,stepMean = 
                            rowMeans(
                              cbind(
                              euclid(lag(X, 2),lag(Y, 2),X,Y),
                              euclid(lag(X, 1),lag(Y, 1),X,Y),
                              euclid(X,Y,lead(X, 1),lead(Y, 1)),
                              euclid(X,Y,lead(X, 2),lead(Y, 2))
                              ))
                          )
# This illustrates very nicely what dplyr can do. You can do basically anything with your grouped 
# intput data, as long as the output is a vector dplyr can deal with it. Note, you've yust coded a
# moving window with n = 5 fixes.

hist(gps_roe_grouped$stepMean, breaks = seq(0,800,25))

# Now we need to define a threshold, for example 50 meters
gps_roe_grouped$moving <- gps_roe_grouped$stepMean > 10

# and with our grouping function, we can name all segements where the animal
# is moving
gps_roe_grouped$seqMoving <- number_groups(gps_roe_grouped$moving,include_next = F)

# We can plot our data to see how our rules fit the visualized trajectory. To do this,
# we have to find a apropriate segment using a subset of our data
ggplot(gps_roe_grouped[100:200,], aes(X,Y)) +
  coord_fixed(ratio = 1) +
  # Use geom_path for trajectories, and not geom_line(). The latter makes an xy-line plot,
  # connecting the datapoints in acending x-order!
  geom_path() +
  # Now add points to the plot where the colour defines whether the animal is moving
  # or not. You have to define a new aesthetic variable (colour = moving). Try defining
  # this aesthetic variable in your first line (ggplot(...)) to see why this doesn't work.
  # Note the coord_fixed(ratio = 1) statement, making sure x- and y-axes are fixed and equal.
  geom_point(aes(colour = moving))

