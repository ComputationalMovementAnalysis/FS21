
library(forcats)

wildschwein_smry <- wildschwein_summer %>%
  st_set_geometry(NULL) %>%
  mutate(
    hour = hour(round_date(DatetimeUTC,"hour")),
    Frucht = ifelse(is.na(Frucht),"other",Frucht),
    Frucht = fct_lump(Frucht, 5,other_level = "other"),
  ) %>%
  group_by(TierName ,hour,Frucht) %>%
  count() %>%
  ungroup() %>%
  group_by(TierName , hour) %>%
  mutate(perc = n / sum(n)) %>%
  ungroup() %>%
  mutate(
    Frucht = fct_reorder(Frucht, n,sum, desc = TRUE)
  )


p1 <- ggplot(wildschwein_smry, aes(hour,perc, fill = Frucht)) +
  geom_col(width = 1) +
  scale_y_continuous(name = "Percentage", labels = scales::percent_format()) +
  scale_x_continuous(name = "Time (rounded to the nearest hour)") +
  facet_wrap(~TierName ) +
  theme_light() +
  labs(title = "Percentages of samples in a given crop per hour",subtitle = "Only showing the most common categories")

p1

p1 +
  coord_polar()  +
  labs(caption = "Same visualization as above, displayed in a polar plot")
