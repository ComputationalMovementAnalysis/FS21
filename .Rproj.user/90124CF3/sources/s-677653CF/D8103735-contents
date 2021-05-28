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


