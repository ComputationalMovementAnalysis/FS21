#############################################################################
## Piping commands with magrittr package ####################################
#############################################################################

# Normally, R reads the commands from inside outwards. If the operation is complex, it can
# be difficult for human beings to write and grasp such code. With the symbol %>% we can chain
# commands in a linear fashion, closer to human thinking. 
# Eg. this:
sqrt(log(10))

# becomes this:
10 %>%
  log() %>%
  sqrt() 

# This doesn't seem like a huge advantage when doing something as simple as sqrt(log(10)),
# but as your commands get more complicated, piping becomes very useful. SAC operations
# is one of the cases where piping can be extremely useful, and dplyr works wonderfully
# with magrittr (magrittr actually comes with dplyr installation)

# Let's consider our "gps_roe_grouped" data and ask the following question: What is the
# mean roe deer speed per hour grouped by weekday and animal considing only our 5min data? 

ave_speed <- mutate(filter(gps_roe_grouped, !is.na(seqMoving)),
                    hour = hour(DateTime),
                    wday = lubridate::wday(DateTime, label = T,abbr = T))
ave_speed <- group_by(ave_speed,hour,wday,TierID)
ave_speed <- summarise(ave_speed, mean_speed = mean(speed))

# You can code this question very nicely with %>%. The code becomes much easier to read 
# and less prone to errors.
ave_speed <- gps_roe_grouped %>%
  filter(!is.na(seqMoving)) %>%
  mutate(
    hour = hour(DateTime),
    wday = lubridate::wday(DateTime, label = T,abbr = T)
  ) %>%
  group_by(hour,wday,TierID) %>% # NOTE: this will OVERWRITE your previous grouping variables 
  summarise(                     # and will save them to the your new data.frame (in this case
    mean_speed = mean(speed)     # "ave_speed")
  )

# and now visualize this data with a ggplot
ggplot(ave_speed, aes(hour, mean_speed, color = TierID)) +
  geom_line() +
  facet_grid(wday~.)