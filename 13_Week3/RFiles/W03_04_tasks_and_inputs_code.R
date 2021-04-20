
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


summarise(st_set_geometry(wildschwein_BE,NULL), mean_timelag = mean(timelag, na.rm = T))

#- chunkend



# Store coordinates in a new variable

coordinates <- st_coordinates(wildschwein_BE)

head(coordinates)





knitr::include_graphics("02_Images/laube_2011_2.jpg")

#- chunkend

nrow(caro60)
nrow(caro60_3)
nrow(caro60_6)
nrow(caro60_9)
