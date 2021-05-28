
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
