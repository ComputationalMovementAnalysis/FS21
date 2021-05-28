
## Solutions




Hover over the code and copy the content by clicking on the clipboard icon on the top right. You can now paste this into an R-Script.



```r

# task 0 ########################################################################

## Load the necessary libraries ################################################

library(readr)        # to import tabular data (e.g. csv)
library(dplyr)        # to manipulate (tabular) data
library(ggplot2)      # to visualize data
library(sf)           # to handle spatial vector data
library(terra)        # To handle raster data
library(lubridate)    # To handle dates and times

## Import the downloaded csv ##################################################

wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE_2056.csv",",") # adjust path

wildschwein_BE <- st_as_sf(wildschwein_BE, coords = c("E", "N"), crs = 2056, remove = FALSE)


# task 1 ########################################################################

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


# task 2 ########################################################################

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


# task 3 ########################################################################

caro <- read_delim("00_Rawdata/caro60.csv",",")

caro[seq(1, nrow(caro),3), ]

caro_3 <- caro[seq(1, nrow(caro),3), ]

caro_6 <- caro[seq(1, nrow(caro),6), ]

caro_9 <- caro[seq(1, nrow(caro),9), ]



caro <- caro %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )

caro_3 <- caro_3 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )

caro_6 <- caro_6 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )


caro_9 <- caro_9 %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )


ggplot() +
  geom_point(data = caro, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_path(data = caro, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_point(data = caro_3, aes(E,N, colour = "3 minutes")) +
  geom_path(data = caro_3, aes(E,N, colour = "3 minutes")) +
  labs(color="Trajectory", title = "Comparing original- with 3 minutes-resampled data")  +
  theme_minimal()

ggplot() +
  geom_point(data = caro, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_path(data = caro, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_point(data = caro_6, aes(E,N, colour = "6 minutes")) +
  geom_path(data = caro_6, aes(E,N, colour = "6 minutes")) +
  labs(color="Trajectory", title = "Comparing original- with 6 minutes-resampled data") +
  theme_minimal()

ggplot() +
  geom_point(data = caro, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_path(data = caro, aes(E,N, colour = "1 minute"), alpha = 0.2) +
  geom_point(data = caro_9, aes(E,N, colour = "9 minutes")) +
  geom_path(data = caro_9, aes(E,N, colour = "9 minutes"))+
  labs(color="Trajectory", title = "Comparing original- with 9 minutes-resampled data") +
  theme_minimal()


ggplot() +
  geom_line(data = caro, aes(DatetimeUTC,speed, colour = "1 minute")) +
  geom_line(data = caro_3, aes(DatetimeUTC,speed, colour = "3 minutes")) +
  geom_line(data = caro_6, aes(DatetimeUTC,speed, colour = "6 minutes")) +
  geom_line(data = caro_9, aes(DatetimeUTC,speed, colour = "9 minutes")) +
  labs(x = "Time",y = "Speed (m/s)", title = "Comparing derived speed at different sampling intervals") +
  theme_minimal()


# task 4 ########################################################################

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

```

