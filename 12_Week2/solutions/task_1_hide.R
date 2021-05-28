wildschwein_BE <- wildschwein_BE %>%
  mutate(timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")))

ggplot(wildschwein_BE, aes(DatetimeUTC,TierID)) +
  geom_line()

ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 50) +
  lims(x = c(0,15000)) +
  scale_y_log10()


wildschwein_BE %>%
  filter(year(DatetimeUTC)  == 2014) %>%
  ggplot(aes(DatetimeUTC,timelag, colour = TierID)) +
  geom_line() +
  geom_point()
