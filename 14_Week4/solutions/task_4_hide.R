library(purrr)


sabi <- wildschwein_filter %>%
  filter(TierName == "Sabi")

rosa <- wildschwein_filter %>%
  filter(TierName == "Rosa")


wildschwein_join <- full_join(sabi, rosa, by = c("DatetimeRound"), suffix = c("_sabi","_rosa"))


wildschwein_join <- wildschwein_join %>%
  mutate(
    distance = sqrt((E_rosa-E_sabi)^2+(N_rosa-N_sabi)^2),
    meet = distance < 100
  )



