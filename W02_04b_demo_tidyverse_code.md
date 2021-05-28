

## Demo Tidyverse (R-Code)








```r
now <- Sys.time()

later <- now + 10000

time_difference <- difftime(later,now)
time_difference
time_difference <- difftime(later,now,units = "mins")
time_difference
str(time_difference)
time_difference <- as.numeric(difftime(later,now,units = "mins"))

str(time_difference)

numbers <- 1:10

numbers

library(dplyr)

lead(numbers)

lead(numbers,n = 2)

lag(numbers)

lag(numbers,n = 5)

lag(numbers,n = 5, default = 0)
wildschwein <- tibble(
  TierID = c(rep("Hans",5),rep("Klara",5)),
  DatetimeUTC = rep(as.POSIXct("2015-01-01 00:00:00",tz = "UTC")+0:4*15*60, 2)
  )

wildschwein
wildschwein$timelag  <- as.numeric(difftime(lead(wildschwein$DatetimeUTC), wildschwein$DatetimeUTC))

wildschwein <- mutate(wildschwein,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC)))

wildschwein
wildschwein <- group_by(wildschwein,TierID)
wildschwein <- mutate(wildschwein,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC)))



wildschwein
summarise(wildschwein, mean = mean(timelag, na.rm = T))

wildschwein %>%                           # Take wildschwein...
  group_by(TierID) %>%                    # ...group it by TierID
  summarise(                              # Summarise the data...
    mean_timelag = mean(timelag,na.rm = T)# ...by calculating the mean timelag
  )
pigs <- tibble(
  TierID = c(8001,8003,8004,8005,8800,8820,3000,3001,3002,3003,8330,7222),
  sex = c("M","M","M","F","M","M","F","F","M","F","M","F"),
  age= c ("A","A","J","A","J","J","J","A","J","J","A","A"),
  weight = c(50.755,43.409,12.000,16.787,20.987,25.765,22.0122,21.343,12.532,54.32,11.027,88.08)
)

pigs

pigs %>%
    summarise(         
    mean_weight = mean(weight)
  )

pigs %>%
  group_by(sex) %>%
  summarise(         
    mean_weight = mean(weight)
  )

pigs %>%
  group_by(sex,age) %>%
  summarise(         
    mean_weight = mean(weight)
  )

```



