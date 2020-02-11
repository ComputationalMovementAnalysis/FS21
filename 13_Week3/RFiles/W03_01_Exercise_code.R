#- header3 Preperation
#- chunkstart

## install.packages("SimilarityMeasures")
## 
## # The following packages are for optional tasks:
## install.packages("plotly")
## 
## # You don't really need the following packages,
## # we just use them in our figures
## install.packages("ggrepel")

library(tidyverse)
library(sf)

# Import as dataframe
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
    steplength = sqrt((E-lead(E))^2+(N-lead(N))^2),
    speed = steplength/timelag
  )


#- chunkend

#- header3 Input
#- chunkstart

set.seed(10)
n = 20
df <- tibble(X = cumsum(rnorm(n)), Y = cumsum(rnorm(n)))

ggplot(df, aes(X,Y)) +
  geom_path() + 
  geom_point() +
  coord_equal()


df <- df %>%
  mutate(
    nMinus2 = sqrt((lag(X,2)-X)^2+(lag(Y,2)-Y)^2),   # distance to pos -10 minutes
    nMinus1 = sqrt((lag(X,1)-X)^2+(lag(Y,1)-Y)^2),   # distance to pos - 5 minutes
    nPlus1  = sqrt((X-lead(X,1))^2+(Y-lead(Y,1))^2), # distance to pos + 5 mintues
    nPlus2  = sqrt((X-lead(X,2))^2+(Y-lead(Y,2))^2)  # distance to pos +10 minutes
  )


df %>%
  mutate(
    stepMean = mean(c(nMinus2, nMinus1,nPlus1,nPlus2), na.rm = T)
  )

df <- df %>%
  rowwise() %>%
  mutate(
    stepMean = mean(c(nMinus2, nMinus1,nPlus1,nPlus2))
  )

df


df <- df %>% 
  mutate(
    moving = stepMean>1.5
    )

df

ggplot(df, aes(X,Y)) +
  geom_path() + 
  geom_point(aes(colour = moving)) +
  coord_equal()

one_to_ten <- 1:10
one_to_ten
cumsum(one_to_ten)

as.integer(TRUE)
as.integer(FALSE)

TRUE+TRUE


boolvec <- c(FALSE,TRUE,TRUE,TRUE,FALSE,FALSE,TRUE,TRUE)

df_cumsum <- tibble(boolvec = boolvec,cumsum = cumsum(boolvec))

df_cumsum


df_cumsum %>%
  mutate(
    boolvec_inverse = !boolvec,
    cumsum2 = cumsum(boolvec_inverse)
  )



df_cumsum %>%
  mutate(
    cumsum2 = cumsum(!boolvec)
  )
  

#- chunkend

#- header3 Task1
#- chunkstart



caro60 <- read_delim("00_Rawdata/caro60.csv",",")

caro60 <- caro60 %>%
  mutate(
    stepMean = rowMeans(                       # We present here a slightly different 
      cbind(                                   # approach as presented in the input
        sqrt((lag(E,2)-E)^2+(lag(E,2)-E)^2),   # cbind() creates a matrix with the same 
        sqrt((lag(E,1)-E)^2+(lag(E,1)-E)^2),   # number of rows as the original dataframe,
        sqrt((E-lead(E,1))^2+(E-lead(E,1))^2), # but with four columns, and rowMeans() returns 
        sqrt((E-lead(E,2))^2+(E-lead(E,2))^2)  # a single vector (again, with the same number 
        )                                      # of rows as the original dataframe)
      )
  )

#- chunkend

#- header3 Task 2
#- chunkstart


summary(caro60$stepMean)

ggplot(caro60, aes(stepMean)) +
  geom_histogram(binwidth = 1) +
  geom_vline(xintercept = 5)

caro60 <- caro60 %>%
  mutate(
    moving = stepMean > 5
  ) 


#- chunkend

#- header3 Task 3
#- chunkstart


p1 <- caro60 %>%
  ggplot() +
  geom_path(aes(E,N), alpha = 0.5) +
  geom_point(aes(E,N,colour = moving)) +
  theme_minimal() +
  coord_equal()

p1


## 
## library(plotly)
## ggplotly(p1)
## 



#- chunkend

#- header3 Task 4
#- chunkstart


caro60_moveseg <-caro60 %>%
  filter(!is.na(moving)) %>%
  ungroup() %>%
  mutate(
    segment_ID = as.factor(1+cumsum(!moving))
  )  %>%
  filter(moving) %>%
  group_by(segment_ID) %>%
  mutate(
    segment_duration = as.integer(difftime(max(DatetimeUTC),min(DatetimeUTC),units = "mins"))
  ) %>%
  filter(segment_duration >= 3)



bind_rows(mutate(caro60, lab = "before"),mutate(caro60_moveseg,lab = "after")) %>%
  mutate(lab = fct_rev(lab)) %>%
  ggplot(aes(E,N, colour = segment_ID)) +
  geom_path(alpha = 0.5) +
  geom_point() +
  theme_minimal() +
  coord_equal() + 
  facet_wrap(~lab)




#- chunkend

#- header3 Task 5
#- chunkstart


library(ggrepel)
pedestrians <- read_delim("00_Rawdata/pedestrian.csv",",")

pedestrians <- pedestrians %>%
  group_by(TrajID) %>%
  mutate(index = row_number()) %>%
  ungroup() %>%
  mutate(TrajID = as.factor(TrajID))


plotraj <- function(idx,lab = F){
  dat <- pedestrians %>%
    filter(TrajID %in% c(1,idx))
  
  p <- ggplot(dat, aes(E,N, colour = TrajID, label = index)) +
    geom_path(colour = "grey", alpha = 0.5) + 
    geom_point() + 
    # scale_color_discrete(guide = "none") +
    # labs(title = paste("Trajectories 1 and",idx)) +
    theme_minimal() +
    coord_equal()
  
  if(lab == T){
    p <- p + 
      geom_text_repel(data = filter(dat,index == 1 | index %% 2 == 0),
                      aes(E,N,label = index,colour = TrajID),
                      show.legend = FALSE) 
  }
  
  p
}


plotraj(2)



plotraj(3,T) 



plotraj(4)


plotraj(5)



plotraj(6)

#- chunkend

#- header3 Task 6
#- chunkstart


# instead of repeating the same step 6 times, I use purrr::map() 
# which creates a list of dataframes. Feel free to use a method
# with which you feel comfortable.

pedestrians_matrix <- pedestrians %>%
  split(.$TrajID) %>%
  map(function(x){
    x %>%
      select(E,N) %>%
      as.matrix()
  })


library(SimilarityMeasures)

# Again, we use one of the purrr::map_* family of functions
# to calculate three indicies over all 5 pairs in one go.
# As before: feel free to use a different method you feel 
# more comfortable in.


pedest_measures <- imap_dfr(pedestrians_matrix, ~data_frame(
  traj = .y,
  DTW = DTW(.x,pedestrians_matrix[[1]]),
  EditDist = EditDist(.x,pedestrians_matrix[[1]]),
  Frechet = Frechet(.x,pedestrians_matrix[[1]]),
  LCSS = LCSS(.x,pedestrians_matrix[[1]],5,4,4)
  ))



pedest_measures %>%
  gather(key,val,-traj) %>%
  ggplot(aes(traj,val, fill = traj))+ 
  geom_bar(stat = "identity") +
  facet_wrap(~key,scales = "free") +
  theme(legend.position = "none") +
  labs(x = "Comparison trajectory", y = "Value", title = "Computed similarities using different measures \nbetween trajectory 1 to all other trajectories ")

