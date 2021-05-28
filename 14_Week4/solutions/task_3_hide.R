


wildschwein_filter <- wildschwein_filter %>%
  group_by(TierID) %>%
  mutate(
    DatetimeRound = lubridate::round_date(DatetimeUTC,"15 minutes")
  )

head(wildschwein_filter)
