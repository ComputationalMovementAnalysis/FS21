knitr::opts_chunk$set(echo = FALSE, include = FALSE, eval = TRUE, purl = TRUE, collapse = TRUE, warning = FALSE, message = FALSE)

# Store coordinates in a new variable

coordinates <- st_coordinates(wildschwein_BE)

head(coordinates)

colnames(coordinates) <- c("E","N")

wildschwein_BE <- cbind(wildschwein_BE,coordinates)

head(wildschwein_BE)

#- chunkend



knitr::include_graphics("02_Images/laube_2011_2.jpg")

nrow(caro60)
nrow(caro60_3)
nrow(caro60_6)
nrow(caro60_9)

is.data.frame(wildschwein_BE_sf)


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


library(zoo)

example <- rnorm(10)
rollmean(example,k = 3,fill = NA,align = "left")
rollmean(example,k = 4,fill = NA,align = "left")



wildschwein_BE


wildschwein_BE_grouped <- group_by(wildschwein_BE,TierID)

wildschwein_BE_grouped

