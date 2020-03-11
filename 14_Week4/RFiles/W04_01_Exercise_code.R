## Preperation #################################################################


library(tidyverse)
library(sf)
library(lubridate)

# Import as tibble
wildschwein_BE <- read_delim("00_Rawdata/wildschwein_BE.csv",",")

# Convert to sf-object
wildschwein_BE = st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326,remove = FALSE)

# transform to CH1903 LV95
wildschwein_BE <- st_transform(wildschwein_BE, 2056)

# Add geometry as E/N integer Columns
wildschwein_BE <- st_coordinates(wildschwein_BE) %>%
  cbind(wildschwein_BE,.) %>%
  rename(E = X) %>%
  rename(N = Y)

# Compute timelag, steplength and speed
wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")),
    steplength = sqrt((E-lead(E,1))^2+(N-lead(N,1))^2),
    speed = steplength/timelag
  )


#- chunkend

## Input: Creating Functions ###################################################

testfun <- function(){}


testfun()

class(testfun)


testfun <- function(){print("this function does nothing")}

testfun()


testfun <- function(sometext){print(sometext)}

testfun(sometext = "this function does slightly more, but still not much")

# specify two parameters:
# x: the value  with want to take the root from
# n: the root we want to take (2 for 2nd root)

nthroot <- function(x,n){x^(1/n)}

# Test function by taking the second root of 4. 
# Expecting the result to be 2:
nthroot(x = 4,n = 2)


nthroot(27,3)
nthroot(3,3)

nthroot <- function(x,n = 2){x^(1/n)}

# if not stated otherwise, our function takes the square root
nthroot(10)
# We can still overwrite n
nthroot(10,3)


## Task 4 ######################################################################

euclid <- function(x,y,leadval = 1){
  sqrt((x-lead(x,leadval))^2+(y-lead(y,leadval))^2)
}

## Task 2 ######################################################################

wildschwein_filter <- wildschwein_BE %>%
  filter(DatetimeUTC > "2015-04-01",
         DatetimeUTC < "2015-04-15") 

wildschwein_filter %>%
  group_by(TierID) %>%
  summarise() %>%
  st_convex_hull() %>%
  ggplot() + geom_sf(aes(fill = TierID),alpha = 0.3)

wildschwein_filter <- wildschwein_filter %>%
  filter(TierID != "018A")


#- chunkend

## Task 3 ######################################################################


head(wildschwein_filter)

ggplot(wildschwein_filter, aes(DatetimeUTC,timelag/60, colour = TierID)) + 
  geom_line() + 
  geom_point()+ 
  expand_limits(y = 0) +
  facet_grid(TierID~.)


wildschwein_filter <- wildschwein_filter %>%
  group_by(TierID) %>%
  mutate(
    DatetimeRound = round_date(DatetimeUTC,"15 minutes")
  )

wildschwein_filter %>%
  mutate(delta = abs(as.integer(difftime(DatetimeUTC,DatetimeRound, units = "secs")))) %>%
  ggplot(aes(delta)) +
  geom_histogram(binwidth = 1) +
  labs(x = "Absolute time difference between original- and rounded Timestamp",
       y = "Number of values")

## Task 4 ######################################################################

wildschwein_join <- wildschwein_filter %>%
  ungroup() %>%
  select(TierID,DatetimeRound,E,N) %>%
  st_set_geometry(NULL) %>%
  split(.$TierID) %>%
  accumulate(~full_join(.x,.y, by = "DatetimeRound")) %>%
  pluck(length(.))


euclid2 <- function(x1,y1,x2,y2){
  sqrt((x1-x2)^2+(y2-y2)^2)
}


wildschwein_join <- wildschwein_join %>%
  mutate(
    distance = euclid2(E.x,N.x,E.y,N.y),
    meet = distance < 100
  )


wildschwein_join

## Task 5 ######################################################################

# Cumsum appraoch from Exercise 3
number_seq = function(bool){
  fac <- as.factor(ifelse(bool,1+cumsum(!bool),NA))
  levels(fac) <- 1:length(levels(fac))
  return(fac)
}

# library(lwgeom)

wildschwein_meet <- wildschwein_join %>%
  mutate(meet_seq = number_seq(meet)) %>%
  filter(meet) %>%
  group_by(meet_seq) %>%
  mutate(meet_time = paste0(meet_seq,": ",strftime(min(DatetimeRound),format = "%d.%m.%Y %H:%M"),"-",strftime(max(DatetimeRound),format = "%H:%M")))

ggplot(wildschwein_join) + 
  geom_point(aes(E.x, N.x),colour = "cornsilk",alpha = 0.2,shape = 4) +
  geom_point(aes(E.y, N.y),colour = "cornsilk4",alpha = 0.2,shape = 4) +
  geom_point(data = wildschwein_meet, aes(E.x,N.x), colour = "red") +
  geom_point(data = wildschwein_meet, aes(E.y,N.y), colour = "blue") +
  coord_equal() +
  facet_wrap(~meet_time) +
  theme_light() +
  theme(axis.title = element_blank(),axis.text = element_blank())


## Task 6 ######################################################################

## 
## meanmeetpoints <- wildschwein_join %>%
##   filter(meet) %>%
##   mutate(
##     E.mean = (E.x+E.y)/2,
##     N.mean = (N.x+N.y)/2
## 
##   )
## 
## library(plotly)
## plot_ly(wildschwein_join, x = ~E.x,y = ~N.x, z = ~DatetimeRound,type = "scatter3d", mode = "lines") %>%
##   add_trace(wildschwein_join, x = ~E.y,y = ~N.y, z = ~DatetimeRound) %>%
##   add_markers(data = meanmeetpoints, x = ~E.mean,y = ~N.mean, z = ~DatetimeRound) %>%
##   layout(scene = list(xaxis = list(title = 'E'),
##                       yaxis = list(title = 'N'),
##                       zaxis = list(title = 'Time')))
## 

## wildschwein_join %>%
##   filter(DatetimeRound<"2015-04-04") %>%
##   plot_ly(x = ~E.x,y = ~N.x, z = ~DatetimeRound,type = "scatter3d", mode = "lines") %>%
##   add_trace(wildschwein_join, x = ~E.y,y = ~N.y, z = ~DatetimeRound) %>%
##   add_markers(data = meanmeetpoints, x = ~E.mean,y = ~N.mean, z = ~DatetimeRound) %>%
##   layout(scene = list(xaxis = list(title = 'E'),
##                       yaxis = list(title = 'N'),
##                       zaxis = list(title = 'Time')))
