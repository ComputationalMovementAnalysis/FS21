## install.packages("scales")
## install.packages("leaflet")
## install.packages("SimilarityMeasures")
library(tidyverse)
library(CMAtools)
library(sf)




# Import as tibble
wildschwein_BE <- read_delim("../CMA_FS2018_Filestorage/wildschwein_BE.csv",",")

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
    steplength = euclid(lead(E, 1),lead(N, 1),E,N),
    speed = steplength/timelag
  )

## Input: cut vecotrs by intervals ####################
ages <- c(20,25,18,13,53,50,23,43,68,40)
breaks <- seq(0,50,10)

cut(ages,breaks = breaks)

library(CMAtools)

breaks <- c(0,30,60,100)

cut(ages, breaks = breaks, labels = c("young","middle aged","old"))

cut(ages, breaks = breaks, labels = labels_nice(breaks))



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


wildschwein_BE <- wildschwein_BE %>%
  group_by(TierID) %>%
  mutate(
    samplingInt = cut(timelag,breaks = breaks,labels = labels_nice(breaks))
  ) 

sample <- data.frame(position = paste0("pos",1:6),samplingInt=c(rep(60,3),rep(120,3)))
sample
sample <- sample %>%
  mutate(
    samplingInt_control = samplingInt == lead(samplingInt,1),
    samplingInt_group = number_groups(samplingInt_control,include_first_false = T)
  )

sample
set.seed(10)
X = cumsum(rnorm(20))
Y = cumsum(rnorm(20))

plot(X,Y, type = "l")

nMinus2 <- euclid(lag(X, 2),lag(Y, 2),X,Y)   # distance to pos. -10 minutes
nMinus1 <- euclid(lag(X, 1),lag(Y, 1),X,Y)   # distance to pos.  -5 minutes
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

## Task 2 ####################

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
## Task 3 ####################


summary(wildschwein_BE$stepMean)

ggplot(wildschwein_BE, aes(stepMean)) +
  geom_histogram(binwidth = 1) +
  lims(x = c(0,100)) +
  geom_vline(xintercept = 15)


wildschwein_BE <- wildschwein_BE %>%
  mutate(
    segment = ifelse(stepMean > 15,"move","stop")
  )

wildschwein_BE[20:50,] %>%
  filter(!is.na(segment)) %>%
  ggplot() +
  geom_path(aes(E,N)) +
  geom_point(aes(E,N,colour = segment)) +
  theme_minimal() +
  coord_equal()


## Task 3 (Optional) #########################

library(scales)
library(leaflet)

if (knitr::is_html_output()){
  library(leaflet)
  library(scales)
  factpal <- colorFactor(hue_pal()(2), wildschwein_BE$segment)

# checking to see if this all makes sense in leaflet: (or better ggplot?)
  wildschwein_BE[0:200,] %>%
    filter(!is.na(segment)) %>%
    leaflet() %>%
    addCircles(radius = 1,lng = ~Long, lat = ~Lat, color = ~factpal(segment)) %>%
    addPolylines(opacity = 0.1,lng = ~Long, lat = ~Lat) %>%
    addTiles() %>%
    addLegend(pal = factpal, values = ~segment, title = "Animal moving?")
} else{print("Interactive map only available in the online version of this document")}
pedestrians <- read_delim("../CMA_FS2018_Filestorage/pedestrian.csv",",")

pedestrians <- pedestrians %>%
  group_by(TrajID) %>%
  mutate(index = row_number())


plotraj <- function(idx,lab = F){
  dat <- pedestrians %>%
    filter(TrajID %in% c(1,idx))
  
  p <- ggplot(dat, aes(E,N, colour = as.factor(TrajID), label = index)) +
    geom_path(colour = "grey", alpha = 0.5) + 
    geom_point() + 
    scale_color_discrete(guide = "none") +
    labs(title = paste("Trajectories 1 and",idx)) +
    theme_minimal()
  
  if(lab == T) p <- p + geom_text_repel(data = filter(dat,index == 1 | index %% 2 == 0),aes(E,N,label = index,colour = as.factor(TrajID)),inherit.aes = FALSE) + labs(subtitle = "Every second position labeled with index")
  
  p
}


plotraj(2)

plotraj(3,T) 

plotraj(4)
plotraj(5)

plotraj(6)


## 
## 
## traj1 <- pedestrians %>%
##       filter(TrajID == 1) %>% # Change value 1 to 2,3 etc to
##       as.data.frame() %>%     # filter for the other trajectories
##       dplyr::select(E,N) %>%
##       as.matrix()

# instead of repeating the same step 6 times, we use purrr::map() 
# which creates a list of dataframes. Feel free to use a method
# with which you feel comfortable.
pedestrians_l <- unique(pedestrians$TrajID) %>%
  map(function(x){
    pedestrians %>%
      filter(TrajID == x) %>%
      as.data.frame() %>%
      dplyr::select(E,N) %>%
      as.matrix()
  })
library(SimilarityMeasures)

# Again, we use one of the purrr::map_* family of functions
# to calculate three indicies over all 5 pairs in one go.
# As before: feel free to use a different method you feel 
# more comfortable in.
pedest_measures <- map_df(pedestrians_l, ~data_frame(
  DTW = DTW(.x,pedestrians_l[[1]]),
  EditDist = EditDist(.x,pedestrians_l[[1]]),
  Frechet = Frechet(.x,pedestrians_l[[1]])
  ))

pedest_measures %>%
  rownames_to_column("traj") %>%
  slice(2:nrow(.)) %>%
  gather(key,val,-traj) %>%
  ggplot(aes(traj,val))+ 
  geom_bar(stat = "identity") +
  facet_wrap(~key,scales = "free") +
  labs(title = "Comparing Trajectory 1 to trajectories 2 to 6", x = "Trajectory", y = "Value")

wildschwein_BE <- mutate(wildschwein_BE,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs")))
