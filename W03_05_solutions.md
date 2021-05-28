
## Solutions




Hover over the code and copy the content by clicking on the clipboard icon on the top right. You can now paste this into an R-Script.



```r

# task 1 ########################################################################

library(readr)
library(dplyr)
library(ggplot2)


caro60 <- read_delim("00_Rawdata/caro60.csv",",")

caro60 <- caro60 %>%
  mutate(
    stepMean = rowMeans(                       
      cbind(                                   
        sqrt((lag(E,3)-E)^2+(lag(E,3)-E)^2),   
        sqrt((lag(E,2)-E)^2+(lag(E,2)-E)^2),   
        sqrt((lag(E,1)-E)^2+(lag(E,1)-E)^2),   
        sqrt((E-lead(E,1))^2+(E-lead(E,1))^2),  
        sqrt((E-lead(E,2))^2+(E-lead(E,2))^2),
        sqrt((E-lead(E,3))^2+(E-lead(E,3))^2)  
        )                                        
    )
  )

# Note: 
# We present here a slightly different approach as presented in the input:
# - cbind() creates a matrix with the same number of rows as the original dataframe
# - It has 6 columns, one for each Euclidean distance calculation
# - rowMeans() returns a single vector with the same number of rows as the original dataframe


# task 2 ########################################################################

summary(caro60$stepMean)

ggplot(caro60, aes(stepMean)) +
  geom_histogram(binwidth = 1) +
  geom_vline(xintercept = mean(caro60$stepMean,na.rm = TRUE))

caro60 <- caro60 %>%
  mutate(
    static = stepMean < mean(caro60$stepMean,na.rm = TRUE)
  ) 


# task 3 ########################################################################

caro60 %>%
  ggplot() +
  geom_path(aes(E,N), alpha = 0.5) +
  geom_point(aes(E,N,colour = static)) +
  theme_minimal() +
  coord_equal()




# task 4 ########################################################################

caro60 <-caro60 %>%
  mutate(
    segment_ID = rle_id(static)
  )

caro60_moves <- caro60 %>%
  filter(!static)


p1 <- ggplot(caro60_moves, aes(E, N, color = segment_ID)) +
  geom_point() +
  geom_path() +
  coord_equal() +
  theme(legend.position = "none") +
  labs(subtitle =  "All segments (uncleaned)")


p2 <- caro60_moves %>%
  group_by(segment_ID) %>%
  mutate(duration = as.integer(difftime(max(DatetimeUTC),min(DatetimeUTC),"mins"))) %>%
  filter(duration > 5) %>%
  ggplot(aes(E, N, color = segment_ID))+
  # geom_point(data = caro60, color = "black") +
  geom_point() +
  geom_path() +
  coord_equal() +
  theme(legend.position = "none") +
  labs(subtitle = "Long segments (removed segements <5 minutes)")




# task 5 ########################################################################

pedestrians <- read_delim("00_Rawdata/pedestrian.csv",",")


ggplot(pedestrians, aes(E,N)) +
  geom_point(data = dplyr::select(pedestrians, -TrajID),alpha = 0.1) +
  geom_point(aes(color = as.factor(TrajID)), size = 2) +
  geom_path(aes(color = as.factor(TrajID))) +
  facet_wrap(~TrajID,labeller = label_both) +
  coord_equal() +
  theme_minimal() +
  labs(title = "Visual comparison of the 6 trajectories", subtitle = "Each subplot highlights a trajectory") +
  theme(legend.position = "none")





# task 6 ########################################################################

library(SimilarityMeasures)  # for the similarity measure functions

# all functions compare two trajectories (traj1 and traj2). Each trajectory
# must be an numeric matrix of n dimensions. Since our dataset is spatiotemporal
# we need to turn our Datetime column from POSIXct to integer:

pedestrians <- pedestrians %>%
  mutate(Datetime_int = as.integer(DatetimeUTC))


# Next, we make an object for each trajectory only containing the
# coordinates in the three-dimensional space and turn it into a matrix

traj1 <- pedestrians %>%
  filter(TrajID == 1) %>%
  dplyr::select(E, N, Datetime_int) %>%
  as.matrix()


# But instead of repeating these lines 6 times, we turn them into a function.
# (this is still more repetition than necessary, use the purr::map if you know 
# how!)

df_to_traj <- function(df, traj){
  df %>%
    filter(TrajID == traj) %>%
    dplyr::select(E, N, Datetime_int) %>%
    as.matrix()
}

traj2 <- df_to_traj(pedestrians, 2)
traj3 <- df_to_traj(pedestrians, 3)
traj4 <- df_to_traj(pedestrians, 4)
traj5 <- df_to_traj(pedestrians, 5)
traj6 <- df_to_traj(pedestrians, 6)



# Then we can start comparing trajectories with each other

dtw_1_2 <- DTW(traj1, traj2)
dtw_1_3 <- DTW(traj1, traj3)

# ... and so on. Since this also leads to much code repetition, we will 
# demostrate a diffferent approach:

# Instead of creating 6 objects, we can also create a single list containing 6
# elements by using "split" and "purrr::map"

library(purrr)


pedestrians_list <- map(1:6, function(x){
  df_to_traj(pedestrians,x)
})


comparison_df <- map_dfr(2:6, function(x){
  tibble(
    trajID = x,
    DTW = DTW(pedestrians_list[[1]], pedestrians_list[[x]]),
    EditDist = EditDist(pedestrians_list[[1]], pedestrians_list[[x]]),
    Frechet = Frechet(pedestrians_list[[1]], pedestrians_list[[x]]),
    LCSS = LCSS(pedestrians_list[[1]], pedestrians_list[[x]],5,4,4)
  )
})


library(tidyr) # for pivot_longer

comparison_df %>%
  pivot_longer(-trajID) %>%
  ggplot(aes(trajID,value, fill = as.factor(trajID)))+ 
  geom_bar(stat = "identity") +
  facet_wrap(~name,scales = "free") +
  theme(legend.position = "none") +
  labs(x = "Comparison trajectory", y = "Value", title = "Computed similarities using different measures \nbetween trajectory 1 to all other trajectories ")

```

