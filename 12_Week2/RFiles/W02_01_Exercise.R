# install.packages("zoo")
# 
# devtools::install_git("https://github.engineering.zhaw.ch/PatternsTrendsEnvironmentalData/CMAtools.git")
## wildschwein_BE$timelag  <- difftime(lead(wildschwein_BE$DatetimeUTC),wildschwein_BE$DatetimeUTC)
## wildschwein_BE  <- wildschwein_BE %>%
##   mutate(
##     timelag = difftime(lead(DatetimeUTC),DatetimeUTC)
##   )
## 
wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    timelag = difftime(lead(DatetimeUTC),DatetimeUTC,units = "mins"),
    timelag = as.numeric(timelag)
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


ages <- c(20,25,18,13,53,50,23,43,68,40)
breaks <- seq(0,50,10)

cut(ages,breaks = breaks)
cut(ages, breaks = c(0,30,60,100), labels = c("young","middle aged","old"))
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
    steplength = euclid(lead(E),lead(N),E,N),
    speed = steplength/timelag
  )




library(zoo)

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

nMinus2 <- euclid(lag(X, 2),lag(Y, 2),X,Y)  # distance to pos. -10 minutes
nMinus1 <- euclid(lag(X, 1),lag(Y, 1),X,Y)  # distance to pos.  -5 minutes
nPlus1  <- euclid(X,Y,lead(X, 1),lead(Y, 1)) # distance to pos   +5 mintues
nPlus2  <- euclid(X,Y,lead(X, 2),lead(Y, 2)) # distance to pos  +10 minutes

# Use cbind to bind all rows to a matrix
distances <- cbind(nMinus2,nMinus1,nPlus1,nPlus2)
distances

# This just gives us the overall mean
mean(distances, na.rm = T)

# We therefore need the function `rowMeans()`
rowmeans <- rowMeans(distances)
cbind(distances,rowmeans)

# and if we put it all together:
rowMeans(
  cbind(
    euclid(lag(X, 2),lag(Y, 2),X,Y),
    euclid(lag(X, 1),lag(Y, 1),X,Y),  
    euclid(X,Y,lead(X, 1),lead(Y, 1)), 
    euclid(X,Y,lead(X, 2),lead(Y, 2))
  )
)
## NA
