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
