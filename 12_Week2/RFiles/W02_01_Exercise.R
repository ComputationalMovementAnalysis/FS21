## install.packages("devtools")
## install.packages("zoo")
## 
## devtools::install_git("https://github.engineering.zhaw.ch/PatternsTrendsEnvironmentalData/CMAtools.git")
library(CMAtools)
library(zoo)
## Task 1 ####################

ggplot(wildschwein_BE, aes(DatetimeUTC,TierID)) +
  geom_line()

wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "mins"))
  )


ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 50)

ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 1) +
  lims(x = c(0,100)) +
  scale_y_log10()

wildschwein_BE[1:50,] %>%
  ggplot(aes(DatetimeUTC,timelag)) +
  geom_line() +
  geom_point()


## Task 2 ####################

ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 0.1) +
  scale_x_continuous(breaks = seq(0,400,20),limits = c(0,400)) +
  # scale_x_continuous(breaks = seq(0,50,1),limits = c(0,50)) +
  scale_y_log10()

wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    samplingInt = cut(timelag,breaks = c(0,5,seq(10,195,15)))
  ) 

wildschwein_BE %>%
  group_by(samplingInt) %>%
  summarise(
    n = n()
  ) %>%
  ggplot(aes(samplingInt,n)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_log10()


## Task 3 ####################

wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID,samplingInt) %>%
  mutate(
    steplength = euclid(lead(E),lead(N),E,N),
    speed = steplength/timelag
  )

ggplot(wildschwein_BE, aes(samplingInt,speed,group = samplingInt)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0,100))

example <- rnorm(10)
rollmean(example,k = 3,fill = NA,align = "left")
rollmean(example,k = 4,fill = NA,align = "left")

## Task 4 ####################


wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    speed2 = rollmean(speed,3,NA,align = "left"),
    speed3 = rollmean(speed,5,NA,align = "left"),
    speed4 = rollmean(speed,10,NA,align = "left")
  )

wildschwein_BE[1:30,] %>%
  gather(key,val,c(speed,speed2,speed3,speed4)) %>%
  ggplot(aes(DatetimeUTC,val,colour = key,group = key)) +
  geom_point() +
  geom_line() 

## Task 5 ####################

wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    stepMean = rowMeans(
      cbind(
        euclid(lag(E, 2),lag(N, 2),E,N),
        euclid(lag(E, 1),lag(N, 1),E,N),
        euclid(E,N,lead(E, 1),lead(N, 1)),
        euclid(E,N,lead(E, 2),lead(N, 2))
        )
      )
  )
## NA
