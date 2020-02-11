#- header3 Preperation
#- chunkstart

library(tidyverse)
library(sf)
library(lubridate)

wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")

wildschwein_BE = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326)

wildschwein_BE <- st_transform(wildschwein_BE, 2056)

#- chunkend

#- header3 Demo Tidyverse
#- chunkstart

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

## summarise(wildschwein_BE, mean = mean(timelag, na.rm = T))


summarise(st_set_geometry(wildschwein_BE,NULL), mean_timelag = mean(timelag, na.rm = T))


wildschwein_BE %>%                     # Take wildschwein_BE...
  st_set_geometry(NULL) %>%            # ...remove the geometry column...
  group_by(TierID) %>%                 # ...group it by TierID
  summarise(                           # Summarise the data...
    mean_timelag = mean(timelag,na.rm = T) # ...by calculating the mean timelag
  )

pigs = data.frame(
  TierID=c(8001,8003,8004,8005,8800,8820,3000,3001,3002,3003,8330,7222),
  sex=c("M","M","M","F","M","M","F","F","M","F","M","F"),
  age=c("A","A","J","A","J","J","J","A","J","J","A","A"),
  weight=c(50.755,43.409,12.000,16.787,20.987,25.765,22.0122,21.343,12.532,54.32,11.027,88.08)
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


#- chunkend

#- header3 Task 1
#- chunkstart


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
  



#- chunkend

#- header3 Input
#- chunkstart

# Store coordinates in a new variable

coordinates <- st_coordinates(wildschwein_BE)

head(coordinates)

colnames(coordinates) <- c("E","N")

wildschwein_BE <- cbind(wildschwein_BE,coordinates)

head(wildschwein_BE)

#- chunkend

#- header3 Task 2
#- chunkstart


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

#- chunkend

#- header3 Task 3
#- chunkstart

caro60 <- read_delim("00_Rawdata/caro60.csv",",") %>%
  st_as_sf(coords = c("E", "N"), crs = 2056, remove = FALSE)
  

caro60_3 <- caro60 %>%
  slice(seq(1,nrow(.),3)) # the dot (".") represents the piped dataset

caro60_6 <- caro60 %>%
  slice(seq(1,nrow(.),6))

caro60_9 <- caro60 %>%
  slice(seq(1,nrow(.),9))

nrow(caro60)
nrow(caro60_3)
nrow(caro60_6)
nrow(caro60_9)


caro60 <- caro60 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )

caro60_3 <- caro60_3 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )

caro60_6 <- caro60_6 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )


caro60_9 <- caro60_9 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )





ggplot() +
  geom_point(data = caro60, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_path(data = caro60, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_point(data = caro60_3, aes(E,N, colour = "3 minutes")) +
  geom_path(data = caro60_3, aes(E,N, colour = "3 minutes")) +
  labs(color="Trajectory", title = "Comparing original- with 3 minutes-resampled data")  +
  theme_minimal()

ggplot() +
  geom_point(data = caro60, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_path(data = caro60, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_point(data = caro60_6, aes(E,N, colour = "6 minutes")) +
  geom_path(data = caro60_6, aes(E,N, colour = "6 minutes")) +
  labs(color="Trajectory", title = "Comparing original- with 6 minutes-resampled data") +
  theme_minimal()

ggplot() +
  geom_point(data = caro60, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_path(data = caro60, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_point(data = caro60_9, aes(E,N, colour = "9 minutes")) +
  geom_path(data = caro60_9, aes(E,N, colour = "9 minutes"))+
  labs(color="Trajectory", title = "Comparing original- with 9 minutes-resampled data") +
  theme_minimal()


ggplot() +
  geom_line(data = caro60, aes(DatetimeUTC,speed, colour = "1 minute")) +
  geom_line(data = caro60_3, aes(DatetimeUTC,speed, colour = "3 minutes")) +
  geom_line(data = caro60_6, aes(DatetimeUTC,speed, colour = "6 minutes")) +
  geom_line(data = caro60_9, aes(DatetimeUTC,speed, colour = "9 minutes")) +
  labs(x = "Time",y = "Speed (m/s)", title = "Comparing derived speed at different sampling intervals") +
  theme_minimal()


#- chunkend

#- header3 Task 4
#- chunkstart


library(zoo)

example <- rnorm(10)
rollmean(example,k = 3,fill = NA,align = "left")
rollmean(example,k = 4,fill = NA,align = "left")



caro60 <- caro60 %>%
  mutate(
    speed3 = rollmean(speed,3,NA,align = "left"),
    speed6 = rollmean(speed,6,NA,align = "left"),
    speed9 = rollmean(speed,9,NA,align = "left")
  )

caro60 %>%
  gather(key,val,c(speed,speed3,speed6,speed9)) %>%
  ggplot(aes(DatetimeUTC,val,colour = key,group = key)) +
  # geom_point() +
  geom_line() 

#- chunkend

#- header3 Task 5
#- chunkstart

library(grid) # just for the arrows


# Advanced solution including the building of functions. Only for very motivated students!

euclid <- function(x1,y1,x2,y2){
  return(sqrt((x1-x2)^2+(y1-y2)^2))
}
turning_angle <- function(x,y,lead_lag = 1){
  if(length(x) < 3){stop("Minimum length of x and y is 3")}
  if(length(x) != length(y)){stop("x and y must be of the same length")}
  p1x <- lag(x,lead_lag)
  p1y <- lag(y,lead_lag)
  p2x <- x
  p2y <- y
  p3x <- lead(x,lead_lag)
  p3y <- lead(y,lead_lag)
  p12 <- euclid(p1x,p1y,p2x,p2y)
  p13 <- euclid(p1x,p1y,p3x,p3y)
  p23 <- euclid(p2x,p2y,p3x,p3y)
  rad <- acos((p12^2+p23^2-p13^2)/(2*p12*p23))
  grad <- (rad*180)/pi
  grad[p12 == 0 | p23 == 0] <- NA
  d <-  (p3x-p1x)*(p2y-p1y)-(p3y-p1y)*(p2x-p1x)
  d <- ifelse(d == 0,1,d)
  d[d>0] <- 1
  d[d<0] <- -1
  d[d==0] <- 1
  turning <- grad*d*-1+180
  return(turning)
}

# Running the functions on some dummy data:
set.seed(20)
data.frame(x = cumsum(rnorm(10)),y = cumsum(rnorm(10))) %>%
  mutate(angle = as.integer(turning_angle(x,y))) %>%
  ggplot(aes(x,y)) +
  geom_segment(aes(x = lag(x), y = lag(y), xend = x,yend = y),arrow = arrow(length = unit(0.5,"cm"))) +
  geom_label(aes(label = paste0(angle,"°")),alpha = 0.4,nudge_x = 0.2, nudge_y = 0.2) +
  coord_equal()

#- chunkend
