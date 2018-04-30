

peds <- read_delim("../CMA_FS2018_Filestorage/pedestrian.csv",",")

peds <- peds %>%
  select(-c(index,OBJECTID,comment)) %>%
  st_as_sf(coords = c("POINT_X","POINT_Y"), crs = 2056,remove = F)


peds <- peds %>%
  group_by(TrajID) %>%
  mutate(
    datetime = as.POSIXct("2015-03-01 13:00:00") + 1:n()*60
  )

peds %>%
  as.data.frame() %>%
  dplyr::select(-geometry) %>%
  rename(E = POINT_X) %>%
  rename(N = POINT_Y) %>%
  rename(DatetimeUTC = datetime) %>%
  write_csv("../CMA_FS2018_Filestorage/pedestrian.csv")

peds_mat <- 1:6 %>%
  map(function(x){
    peds %>%
      filter(TrajID == x) %>%
      as.data.frame() %>%
      select(POINT_X,POINT_Y) %>%
      as.matrix()
  })
  
EditDist(peds_mat[[1]], peds_mat[[6]])
