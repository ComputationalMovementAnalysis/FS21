## install.packages("zoo")
## 
## devtools::install_git("https://github.engineering.zhaw.ch/PatternsTrendsEnvironmentalData/CMAtools.git")
wildschwein_BE <- ungroup(wildschwein_BE)
## Demo Tidyverse ################
now <- Sys.time()

later <- now + 10000

difftime(later,now)
time_difference <- difftime(later,now,units = "mins")

time_difference
str(time_difference)
time_difference <- as.numeric(difftime(later,now,units = "mins"))

str(time_difference)

numbers <- 1:10

numbers
lead(numbers)

lead(numbers,n = 2)

lag(numbers)

lag(numbers,n = 5)

lag(numbers,n = 5, default = 0)
lead(numbers)-numbers
wildschwein_BE$timelag  <- as.numeric(difftime(lead(wildschwein_BE$DatetimeUTC),wildschwein_BE$DatetimeUTC,units = "secs"))

wildschwein_BE <- mutate(wildschwein_BE,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")))
summary(wildschwein_BE$timelag)
wildschwein_BE <- group_by(wildschwein_BE,TierID)
wildschwein_BE <- mutate(wildschwein_BE,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")))

summary(wildschwein_BE$timelag)
## 
## summarise(wildschwein_BE, mean = mean(timelag, na.rm = T))
## 
summarise(group_by(as.data.frame(wildschwein_BE),TierID), mean_timelag = mean(timelag, na.rm = T))

wildschwein_BE %>%                     # Take wildschwein_BE...
  as.data.frame() %>%                  # ...convert it to a data.frame...
  group_by(TierID) %>%                 # ...group it by TierID
  summarise(                           # Summarise the data..
    mean_timelag = mean(timelag,na.rm = T) # ... by calculating the mean timelag
  )
## Task 1 ####################

ggplot(wildschwein_BE, aes(DatetimeUTC,TierID)) +
  geom_line()

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


## Input: cut vecotrs by intervals ####################
ages <- c(20,25,18,13,53,50,23,43,68,40)
breaks <- seq(0,50,10)

cut(ages,breaks = breaks)
cut(ages, breaks = c(0,30,60,100), labels = c("young","middle aged","old"))
## Task 2 ####################

breaks <- c(0,40,80,300,600,1200,2500,3000,4000,7500,110000)



ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 10) +
  lims(x = c(0,600)) +
  scale_y_log10() +
  geom_vline(xintercept = breaks, col = "red")

ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 10) +
  lims(x = c(600,1200)) +
  scale_y_log10() +
  geom_vline(xintercept = breaks, col = "red")


ggplot(wildschwein_BE, aes(timelag)) +
  geom_histogram(binwidth = 10) +
  lims(x = c(1200,10000)) +
  scale_y_log10() +
  geom_vline(xintercept = breaks, col = "red")

labels_nice <- function(breaks){
  return(paste(lag(breaks,default = NULL),lead(breaks,default = NULL),sep="-"))
}

# todo: noch in CMA Tools integrieren


wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    samplingInt = cut(timelag,breaks = breaks,labels = labels_nice(breaks))
  ) 

wildschwein_BE %>%
  as.data.frame() %>%
  group_by(samplingInt) %>%
  summarise(
    n = n()
  ) %>%
  ggplot(aes(samplingInt,n)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_log10()



wildschwein_BE

# Store coordinates in a new variable
coordinates <- st_coordinates(wildschwein_BE)

head(coordinates)
colnames(coordinates) <- c("E","N")

wildschwein_BE <- cbind(wildschwein_BE,coordinates)
## Task 3 ####################

library(CMAtools)

wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID,samplingInt) %>%
  mutate(
    steplength = euclid(lead(E, 1),lead(N, 1),E,N),
    speed = steplength/timelag
  )



sample <- data.frame(position = paste0("pos",1:6),samplingInt=c(rep(60,3),rep(120,3)))
sample
sample <- sample %>%
  mutate(
    samplingInt_control = samplingInt == lead(samplingInt,1),
    samplingInt_group = number_groups(samplingInt_control,include_first_false = T)
  )

sample
wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    samplingInt_T = samplingInt == lead(samplingInt),
    group = number_groups(samplingInt_T,include_first_false = T)
  ) %>%
  dplyr::select(-samplingInt_T)

wildschwein_BE_short <- wildschwein_BE %>%
  filter(samplingInt == "40-80")

wildschwein_BE_short <- wildschwein_BE_short %>%
  filter(group == 9) %>%
  slice(1:100)


wildschwein_BE_3 <- wildschwein_BE_short %>%
  slice(seq(1,nrow(.),3))

wildschwein_BE_6 <- wildschwein_BE_short %>%
  slice(seq(1,nrow(.),6))


wildschwein_BE_9 <- wildschwein_BE_short %>%
  slice(seq(1,nrow(.),9))

wildschwein_BE_3 <- wildschwein_BE_3 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = euclid(lead(E, 1),lead(N, 1),E,N),
    speed = steplength/timelag
  )

wildschwein_BE_6 <- wildschwein_BE_6 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = euclid(lead(E, 1),lead(N, 1),E,N),
    speed = steplength/timelag
  )


wildschwein_BE_9 <- wildschwein_BE_9 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = euclid(lead(E, 1),lead(N, 1),E,N),
    speed = steplength/timelag
  )


ggplot() +
  geom_point(data = wildschwein_BE_9, aes(E,N), colour = "red") +
  geom_path(data = wildschwein_BE_9, aes(E,N), colour = "red") +
  geom_point(data = wildschwein_BE_6, aes(E,N), colour = "blue") +
  geom_path(data = wildschwein_BE_6, aes(E,N), colour = "blue") +
  geom_point(data = wildschwein_BE_3, aes(E,N), colour = "green") +
  geom_path(data = wildschwein_BE_3, aes(E,N), colour = "green") +
  geom_point(data = wildschwein_BE_short, aes(E,N), colour = "black") +
  geom_path(data = wildschwein_BE_short, aes(E,N), colour = "black")


ggplot() +
  geom_point(data = wildschwein_BE_9, aes(DatetimeUTC,speed), colour = "red") +
  geom_path(data = wildschwein_BE_9, aes(DatetimeUTC,speed), colour = "red") +
  geom_point(data = wildschwein_BE_6, aes(DatetimeUTC,speed), colour = "blue") +
  geom_path(data = wildschwein_BE_6, aes(DatetimeUTC,speed), colour = "blue") +
  geom_point(data = wildschwein_BE_3, aes(DatetimeUTC,speed), colour = "green") +
  geom_path(data = wildschwein_BE_3, aes(DatetimeUTC,speed), colour = "green") +
  geom_point(data = wildschwein_BE_short, aes(DatetimeUTC,speed), colour = "black") +
  geom_path(data = wildschwein_BE_short, aes(DatetimeUTC,speed), colour = "black") +
  labs(x = "Time",y = "Speed (m/s)")

## Task 4 ####################

library(zoo)

example <- rnorm(10)
rollmean(example,k = 3,fill = NA,align = "left")
rollmean(example,k = 4,fill = NA,align = "left")



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
## NA
