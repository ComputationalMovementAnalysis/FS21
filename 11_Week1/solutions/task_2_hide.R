ggplot(wildschwein_BE, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  coord_map() +
  theme(legend.position = "none")
