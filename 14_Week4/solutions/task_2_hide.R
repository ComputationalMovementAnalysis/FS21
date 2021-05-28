wildschwein <- read_delim("00_Rawdata/wildschwein_BE_2056.csv",",")

wildschwein_filter <- wildschwein %>%
  filter(DatetimeUTC > "2015-04-01",
         DatetimeUTC < "2015-04-15") %>%
  filter(TierName %in% c("Rosa", "Sabi"))
