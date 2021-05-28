
wildschwein_summer <- wildschwein_BE %>%
  filter(month(DatetimeUTC) %in% 5:6)
  
wildschwein_summer <-  st_join(wildschwein_summer, crop_fanel)

wildschwein_summer

ggplot(crop_fanel) +
  geom_sf(aes(fill = Frucht)) +
  geom_sf(data = wildschwein_summer)







