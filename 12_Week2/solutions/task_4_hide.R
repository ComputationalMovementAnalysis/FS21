library(zoo)

example <- rnorm(10)
rollmean(example,k = 3,fill = NA,align = "left")
rollmean(example,k = 4,fill = NA,align = "left")



caro <- caro %>%
  mutate(
    speed3 = rollmean(speed,3,NA,align = "left"),
    speed6 = rollmean(speed,6,NA,align = "left"),
    speed9 = rollmean(speed,9,NA,align = "left")
  )

caro %>%
  ggplot() +
  geom_line(aes(DatetimeUTC,speed), colour = "#E41A1C") +
  geom_line(aes(DatetimeUTC,speed3), colour = "#377EB8") +
  geom_line(aes(DatetimeUTC,speed6), colour = "#4DAF4A") +
  geom_line(aes(DatetimeUTC,speed9), colour = "#984EA3")
