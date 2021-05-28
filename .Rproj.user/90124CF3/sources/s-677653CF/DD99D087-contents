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



