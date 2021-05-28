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
