wildschwein_meet <- wildschwein_join %>%
  filter(meet)

ggplot(wildschwein_meet) +
  geom_point(data = sabi, aes(E, N, colour = "sabi"),shape = 16, alpha = 0.3) +
  geom_point(data = rosa, aes(E, N, colour = "rosa"),shape = 16, alpha = 0.3) +
  geom_point(aes(x = E_sabi,y = N_sabi, fill = "sabi"),shape = 21) +
  geom_point(aes(E_rosa, N_rosa, fill = "rosa"), shape = 21) +
  labs(color = "Regular Locations", fill = "Meets") +
  coord_equal(xlim = c(2570000,2571000), y = c(1204500,1205500))
