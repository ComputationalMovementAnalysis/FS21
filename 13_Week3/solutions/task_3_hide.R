caro60 %>%
  ggplot() +
  geom_path(aes(E,N), alpha = 0.5) +
  geom_point(aes(E,N,colour = static)) +
  theme_minimal() +
  coord_equal()


