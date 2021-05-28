wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2)
  )

wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    speed = steplength/timelag
  )
