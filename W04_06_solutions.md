
## Solutions




Hover over the code and copy the content by clicking on the clipboard icon on the top right. You can now paste this into an R-Script.



```r

# task 1 ########################################################################

euclid <- function(x,y,leadval = 1){
  sqrt((x-lead(x,leadval))^2+(y-lead(y,leadval))^2)
}


# task 2 ########################################################################

wildschwein <- read_delim("00_Rawdata/wildschwein_BE_2056.csv",",")

wildschwein_filter <- wildschwein %>%
  filter(DatetimeUTC > "2015-04-01",
         DatetimeUTC < "2015-04-15") %>%
  filter(TierName %in% c("Rosa", "Sabi"))


# task 3 ########################################################################




wildschwein_filter <- wildschwein_filter %>%
  group_by(TierID) %>%
  mutate(
    DatetimeRound = lubridate::round_date(DatetimeUTC,"15 minutes")
  )

head(wildschwein_filter)


# task 4 ########################################################################

library(purrr)


sabi <- wildschwein_filter %>%
  filter(TierName == "Sabi")

rosa <- wildschwein_filter %>%
  filter(TierName == "Rosa")


wildschwein_join <- full_join(sabi, rosa, by = c("DatetimeRound"), suffix = c("_sabi","_rosa"))


wildschwein_join <- wildschwein_join %>%
  mutate(
    distance = sqrt((E_rosa-E_sabi)^2+(N_rosa-N_sabi)^2),
    meet = distance < 100
  )





# task 5 ########################################################################

wildschwein_meet <- wildschwein_join %>%
  filter(meet)

ggplot(wildschwein_meet) +
  geom_point(data = sabi, aes(E, N, colour = "sabi"),shape = 16, alpha = 0.3) +
  geom_point(data = rosa, aes(E, N, colour = "rosa"),shape = 16, alpha = 0.3) +
  geom_point(aes(x = E_sabi,y = N_sabi, fill = "sabi"),shape = 21) +
  geom_point(aes(E_rosa, N_rosa, fill = "rosa"), shape = 21) +
  labs(color = "Regular Locations", fill = "Meets") +
  coord_equal(xlim = c(2570000,2571000), y = c(1204500,1205500))


# task 6 ########################################################################


meanmeetpoints <- wildschwein_join %>%
  filter(meet) %>%
  mutate(
    E.mean = (E_rosa+E_sabi)/2,
    N.mean = (N_rosa+N_sabi)/2
  )

library(plotly)
plot_ly(wildschwein_join, x = ~E_rosa,y = ~N_rosa, z = ~DatetimeRound,type = "scatter3d", mode = "lines") %>%
  add_trace(wildschwein_join, x = ~E_sabi,y = ~N_sabi, z = ~DatetimeRound) %>%
  add_markers(data = meanmeetpoints, x = ~E.mean,y = ~N.mean, z = ~DatetimeRound) %>%
  layout(scene = list(xaxis = list(title = 'E'),
                      yaxis = list(title = 'N'),
                      zaxis = list(title = 'Time')))


wildschwein_join %>%
  filter(DatetimeRound<"2015-04-04") %>%
  plot_ly(x = ~E_rosa,y = ~N_rosa, z = ~DatetimeRound,type = "scatter3d", mode = "lines") %>%
  add_trace(wildschwein_join, x = ~E_sabi,y = ~N_sabi, z = ~DatetimeRound) %>%
  add_markers(data = meanmeetpoints, x = ~E.mean,y = ~N.mean, z = ~DatetimeRound) %>%
  layout(scene = list(xaxis = list(title = 'E'),
                      yaxis = list(title = 'N'),
                      zaxis = list(title = 'Time')))

```

