devtools::install_git("https://github.engineering.zhaw.ch/PatternsTrendsEnvironmentalData/CMAtools.git")

library(lubridate)
library(tidyverse) 
library(sf)
library(CMAtools)


wildschwein_BE <- read_delim("../CMA_FS2018_Filestorage/wildschwein_BE_all.csv",",")


wildschwein_BE <- st_as_sf(wildschwein_BE, coords = c("Long", "Lat"), crs = 4326,remove = FALSE)

wildschwein_BE <- st_transform(wildschwein_BE,2056)


coordinates <- st_coordinates(wildschwein_BE)
colnames(coordinates) <- c("E","N")


wildschwein_BE <- cbind(wildschwein_BE,coordinates)


wildschwein_BE %>%
  as.data.frame() %>%
  group_by(TierName,TierID) %>%
  summarise() %>%
  View()


c("Sabi","Joha","Gab2")
c("Rosa","Isab","Caro")
c("Venu","Evel")


windschwein_BE_int <- wildschwein_BE %>%
  as.data.frame() %>%
  group_by(TierName) %>%
  summarise(
    start = min(DatetimeUTC),
    end = max(DatetimeUTC)
  ) %>%
  mutate(
    interval = as.interval(start,end)
  ) %>%
  select(-c(start,end))

wildschwein_BE %>%
  as.data.frame() %>%
  group_by(TierName) %>%
  summarise()

temp_overlap <- overlap_temporal(windschwein_BE_int,2,1)

mcp <- wildschwein_BE %>%
  group_by(TierID) %>%
  summarise() %>%
  st_convex_hull() 
  

spat_overlap <- overlap_spatial(mcp,"TierID")


spatiotemp_overlap <- temp_overlap & spat_overlap


spatiotemp_overlap <- spatiotemp_overlap %>%
  as.data.frame() %>%
  rownames_to_column("id1") %>%
  gather(id2,bool,-id1) %>%
  filter(bool == TRUE) %>%
  select(-bool)


venu_evel <- temporal_join(as.data.frame(wildschwein_BE),TierName,"Venu","Evel",DatetimeUTC,mult = "first",nomatch = 0)


venu_evel <- venu_evel %>%
  ungroup() %>%
  mutate(
    timediff = abs(as.integer(difftime(DatetimeUTC1,DatetimeUTC2,units = "secs"))),
    distance = euclid(E1,N1,E2,N2),
    timediff_small = timediff < 120,
    distance_small = distance < 100,
    near = timediff_small & distance_small,
    near_nr = number_groups(near)
  )


venu_evel$Emean <- rowMeans(venu_evel[,c("E1","E2")])
venu_evel$Nmean <- rowMeans(venu_evel[,c("N1","N2")])
max(venu_evel$n)
venu_evel <- venu_evel %>%
  filter(near) %>%
  group_by(near_nr) %>%
  mutate(
    gr_dist = mean(distance),
    n = n()
    ) %>%
  filter(n > 10)

hist(venu_evel$n)

for(nr in unique(venu_evel$near_nr)){
  venu_evel %>%
    filter(near_nr == nr)%>%
    ggplot() +
    geom_segment(aes(x = E1,y = N1,xend = E2,yend = N2), colour = "grey",alpha = 0.2) +
    geom_path(aes(E1,N1), colour = "red")+
    geom_path(aes(E2,N2), colour = "blue") +
    geom_label(aes(x = Emean,y = Nmean,label = as.integer(distance))) 
  filename = paste0("../_temp/",nr,".png")
  ggsave(filename)
}



