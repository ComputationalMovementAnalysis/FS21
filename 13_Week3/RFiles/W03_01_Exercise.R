## install.packages("SimilarityMeasures")
## 
## # The following packages are for optional tasks:
## install.packages("scales")
## install.packages("leaflet")
## install.packages("plotly")
## 
## # You don't really need the following packages,
## # we just use them in our figures
## install.packages("cowplot")
## install.packages("ggrepel")
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

set.seed(10)

df <- data.frame(X = cumsum(rnorm(10)), Y = cumsum(rnorm(10)))

ggplot(df, aes(X,Y)) +
  geom_path()

df <- df %>%
  mutate(
    nMinus2 = euclid(lag(X, 2),lag(Y, 2),X,Y),   # distance to pos -10 minutes
    nMinus1 = euclid(lag(X, 1),lag(Y, 1),X,Y),   # distance to pos - 5 minutes
    nPlus1  = euclid(X,Y,lead(X, 1),lead(Y, 1)), # distance to pos + 5 mintues
    nPlus2  = euclid(X,Y,lead(X, 2),lead(Y, 2))  # distance to pos +10 minutes
  ) 

df <- df %>%
  rowwise() %>%
  mutate(
    stepMean = mean(c(nMinus2, nMinus1,nPlus1,nPlus2), na.rm = T)
  )


df <- df %>% 
  mutate(
    moving = stepMean>1.5
    )

df
df
df <- df %>%
  ungroup() %>%  # to remove the rowwise grouping
  mutate(
    moving_group = number_groups(moving)
  )

df


wildschwein_BE_1 <- wildschwein_BE%>%
  filter(timelag > 40 & timelag < 80) %>%
  slice(2:100)

## Task 2 ####################

wildschwein_BE_1 <- wildschwein_BE_1 %>%
  group_by(TierID) %>%
  mutate(
    stepMean = rowMeans(                       # using rowMean() is an alternative
      cbind(                                   # to using rowwise() as described 
        euclid(lag(E, 2),lag(N, 2),E,N),       # in the demo
        euclid(lag(E, 1),lag(N, 1),E,N),
        euclid(E,N,lead(E, 1),lead(N, 1)),
        euclid(E,N,lead(E, 2),lead(N, 2))
        )
      )
  )
## Task 2 ####################


summary(wildschwein_BE_1$stepMean)

ggplot(wildschwein_BE_1, aes(stepMean)) +
  geom_histogram(binwidth = 1) +
  lims(x = c(0,100)) +
  geom_vline(xintercept = 7)

wildschwein_BE_1 <- wildschwein_BE_1 %>%
  mutate(
    movement = stepMean > 7
  ) 


wildschwein_BE_1 %>%  select(DatetimeUTC,E,N,stepMean,movement)

p1 <- wildschwein_BE_1 %>%
  ggplot() +
  geom_path(aes(E,N), alpha = 0.5) +
  geom_point(aes(E,N,colour = movement)) +
  theme_minimal() +
  coord_equal()

p1



if (knitr::is_html_output()){                                                           # uncomment this line...
  library(plotly)
  ggplotly(p1)
} else{print("Interactive map only available in the online version of this document")}  # ... and this line


wildschwein_BE_1 <- wildschwein_BE_1 %>%
  ungroup() %>%
  mutate(
    segment_ID = number_groups(movement,T),
    segment_ID = as.factor(segment_ID)
  ) %>%
  group_by(segment_ID) %>%
  mutate(
    segment_length = difftime(max(DatetimeUTC),min(DatetimeUTC),units = "secs")
  )

library(cowplot)

p2 <- wildschwein_BE_1 %>%
  filter(!is.na(segment_ID)) %>%
  ggplot(aes(E,N, colour = segment_ID, group = segment_ID)) +
  geom_path() +
  geom_point() +
  geom_point(data = filter(wildschwein_BE_1, is.na(segment_ID)),alpha = 0.2) +
  scale_alpha_discrete(range = c(0.1,1)) +
  theme_minimal() +
  coord_equal()
p3 <- wildschwein_BE_1 %>%
  filter(!is.na(segment_ID)) %>%
  filter(segment_length > 300) %>%
  ggplot(aes(E,N, colour = segment_ID, group = segment_ID)) +
  geom_path() +
  geom_point() +
  geom_point(data = filter(wildschwein_BE_1, is.na(segment_ID)),alpha = 0.2) +
  scale_alpha_discrete(range = c(0.1,1)) +
  theme_minimal() +
  coord_equal()

  plot_grid(p1,p2,p3, labels = "auto", ncol = 1)



## Task 4 (Optional) #########################

library(scales)
library(leaflet)

if (knitr::is_html_output()){                                                           # uncomment this line...
  factpal <- colorFactor(hue_pal()(3), wildschwein_BE_1$movement)

  wildschwein_BE_1 %>%
    leaflet() %>%
    addCircles(radius = 1,lng = ~Long, lat = ~Lat, color = ~factpal(movement)) %>%
    addPolylines(opacity = 0.1,lng = ~Long, lat = ~Lat) %>%
    addTiles() %>%
    addLegend(pal = factpal, values = ~movement, title = "Segment")
} else{print("Interactive map only available in the online version of this document")}  # ... and this line

## Task 5 ##################################

library(ggrepel)
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
    # labs(title = paste("Trajectories 1 and",idx)) +
    theme_minimal() +
    coord_equal()
  
  if(lab == T) p <- p + geom_text_repel(data = filter(dat,index == 1 | index %% 2 == 0),aes(E,N,label = index,colour = as.factor(TrajID)),inherit.aes = FALSE) #+ labs(subtitle = "Every second position labeled with index")
  
  p
}

plotraj(2)


plotraj(3,T) 


plotraj(4)

plotraj(5)


plotraj(6)
traj1 <- pedestrians %>%
      filter(TrajID == 1) %>% # Change value 1 to 2,3 etc to  
      as.data.frame() %>%     # filter for the other trajectories
      dplyr::select(E,N) %>%
      as.matrix()


# This is the original data.frame:
head(pedestrians)

# ..and this is the data converted to a matrix:
head(traj1)

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
  Frechet = Frechet(.x,pedestrians_l[[1]]),
  LCSS = LCSS(.x,pedestrians_l[[1]],5,4,4)
  ))



pedest_measures %>%
  rownames_to_column("traj") %>%
  slice(2:nrow(.)) %>%
  gather(key,val,-traj) %>%
  ggplot(aes(traj,val))+ 
  geom_bar(stat = "identity") +
  facet_wrap(~key,scales = "free") +
  labs(x = "Trajectory", y = "Value")

