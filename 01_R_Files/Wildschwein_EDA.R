
# install all packages in library
# install_github() for ggplot
# install_git() for CMAtools
library(devtools)


library(tidyverse)
library(lubridate)
library(leaflet)
library(sp)
library(adehabitatHR)
library(scales)
library(plotly)
library(sf)
library(purrr)
library(stringr)
library(data.table)
library(CMAtools)

euclid <- function(x1,y1,x2,y2){
  return(sqrt((x1-x2)^2+(y1-y2)^2)) 
}

str_remove_trailing <- function(string,trailing_char){
  ifelse(str_sub(string,-1,-1) == trailing_char,str_sub(string,1,-2),string)
}


#############################################################################
## Lesson 1 #################################################################
#############################################################################
# - Set up Rstudio Project
# - Import and clean data
# - Explore Dataset: remove outliers, find sampling interval, make subsets and find overlapping areas of individuals)
# - Make my first simple map


## Read and clean data
wildschweinRAW <- read_delim("20_Rawdata/wildschwein.csv",";")

wildschwein <- rowid_to_column(wildschweinRAW,"fixNr")

wildschwein <- dplyr::select(wildschwein, Tier,DatumUTC,ZeitpUTC,Lat,Long)

wildschwein <- mutate(wildschwein,Tier = str_remove_trailing(Tier,"_"))

wildschwein <- separate(wildschwein, Tier,into = c("TierID","TierName","CollarID"))


wildschwein <- wildschwein %>%
  group_by(TierID) %>%
  mutate(CollarIDfac = LETTERS[as.integer(factor(CollarID))]) %>%
  ungroup() %>%
  mutate(TierID = paste0(TierID,CollarIDfac)) %>%
  select(-CollarIDfac)

wildschwein <- mutate(wildschwein, DatetimeUTC = parse_datetime(ZeitpUTC))

wildschwein <- select(wildschwein, -DatumUTC,-ZeitpUTC)

# warum sind so viele Positionen NA?!
wildschwein <- filter(wildschwein,!is.na(Lat))

# Visualize Points via. lat/long. Note: lat/long are plotted as cartesian coordinates
ggplot(wildschwein, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  coord_fixed(1) +
  theme(legend.position = "none")

wildschwein <- filter(wildschwein,Lat<50)

# turn df into sf-object
wildschwein_sf = st_as_sf(wildschwein, coords = c("Long", "Lat"), crs = 4326, agr = "constant")

# Transform coordinate system
wildschwein_sf <- st_transform(wildschwein_sf, 2056)

bbox <- st_bbox(wildschwein_sf)

str(bbox)

# bbox_area_cart


(bbox[[3]]-bbox[[1]])*(bbox[[4]]- bbox[[2]])/(1000^2)

mcp95 <- mcp_sf(wildschwein_sf,TierID)


ggplot(mcp95) +
  geom_sf(aes(fill = id), alpha = 0.3) +
  geom_sf(data = st_centroid(mcp95), aes(colour = id)) +
  coord_sf(datum = 2056) + 
  theme(
    legend.position = "none",
    panel.grid.major = element_line(colour = "transparent"),
    panel.background = element_rect(fill = "transparent")
    )


# TODO: why does this work without specifying the "id_col"?
overlap_spatial(mcp95)

# Trying to find overlapping time windows:
wildschwein_intervals <- wildschwein %>%
  group_by(TierID) %>%
  summarise(
    min = min(DatetimeUTC,na.rm = T),
    max = max(DatetimeUTC,na.rm = T)
  ) %>%
  ungroup() %>%
  mutate(
    interval = interval(min,max)
  )


# ToDO: make this work with id_col = "null"
overlap_temporal(wildschwein_intervals,"interval","TierID")

overlap_temporal <- matrix(nrow = nrow(wildschwein_intervals),ncol = nrow(wildschwein_intervals))
rownames(overlap_temporal) <- wildschwein_intervals$TierID
colnames(overlap_temporal) <- wildschwein_intervals$TierID
for(row_i in 1:nrow(wildschwein_intervals)){
  for(col_i in 1:nrow(wildschwein_intervals)){
    overlap_temporal[row_i,col_i] <- lubridate::int_overlaps(wildschwein_intervals$interval[row_i,],wildschwein_intervals$interval[col_i,])
  }
}
overlap_temporal[lower.tri(overlap_temporal,T)] <- NA




overlap_spat_temp <- overlap_temporal & overlap_spatial

overlap_spat_temp <- overlap_spat_temp %>%
  as.data.frame() %>%
  rownames_to_column("id1") %>%
  gather(id2,bool,-id1) %>%
  filter(bool == TRUE) %>%
  select(-bool)

wildschwein <- wildschwein_sf %>%
  st_coordinates(wildschwein_sf) %>%
  as_tibble() %>%
  bind_cols(wildschwein)

id1 = overlap_spat_temp$id1[1]
id2 = overlap_spat_temp$id2[1]


wildschwein_dt1 <- wildschwein %>%
  filter(TierID == id1) %>%
  arrange(DatetimeUTC) %>%
  mutate(
    lag = lag(DatetimeUTC),
    lead = lead(DatetimeUTC),
    winBack = ifelse(is.na(lag),0,ceiling(difftime(DatetimeUTC,lag)/2)),
    winFront = ifelse(is.na(lead),0,floor(difftime(lead,DatetimeUTC)/2)-1),
    start = DatetimeUTC-winBack,
    end = DatetimeUTC+winFront
  ) %>%
  select(-c(lag,lead,winBack,winFront)) %>%
  rename_all(function(x){paste0(x,"1")}) %>%
  as.data.table() %>%
  setkey(start1,end1)


wildschwein_dt2 <- wildschwein %>%
  filter(TierID == id2) %>%
  arrange(DatetimeUTC) %>%
  mutate(
    lag = lag(DatetimeUTC),
    lead = lead(DatetimeUTC),
    winBack = ifelse(is.na(lag),0,ceiling(difftime(DatetimeUTC,lag)/2)),
    winFront = ifelse(is.na(lead),0,floor(difftime(lead,DatetimeUTC)/2)-1),
    start = DatetimeUTC-winBack,
    end = DatetimeUTC+winFront
  ) %>%
  select(-c(lag,lead,winBack,winFront)) %>%
  rename_all(function(x){paste0(x,"2")}) %>%
  as.data.table() %>%
  setkey(start2,end2)


wildschwein_dt1$difftime <- as.integer(difftime(wildschwein_dt1$end1,wildschwein_dt1$start1,units = "hours"))
which.max(wildschwein_dt1$difftime)

temporal_join_df <- foverlaps(wildschwein_dt1,wildschwein_dt2,mult = "first",nomatch = 0)

temporal_join <- temporal_join_df %>%
  as.tibble() %>%
  select(-c(start1,end1,start2,end2)) %>%
  mutate(distance = euclid(X1,Y1,X2,Y2)) %>%
  filter(distance < 100)


temporal_join %>%
  ggplot(aes(distance)) +
  geom_histogram(binwidth = 10, colour = "black")

temporal_join

#############################################################################
## Lesson 2 #################################################################
#############################################################################
# - Enrich trajectories (step length, speed, 5min/3hrs)
# - Simple multi-scale analysis (with dplyr summarize for 5min and 3hrs)
# - Moving windows
# - Map back in space



# how many fixes per animal? how many collars per animal? 
wildschwein %>%
  group_by(TierID) %>%
  summarise(
    fixes = n(),
    collars = length(unique(CollarID)),
    names = paste(unique(TierName),collapse = ",")
    )

wildschwein %>%
  group_by(CollarID) %>%
  summarise(
    fixes = n(),
    collars = length(unique(TierID)),
    names = paste(unique(TierName),collapse = ",")
  )

ggplot(wildschwein, aes(DatetimeUTC,TierID, colour = TierID)) +
  geom_line() +
  theme(legend.position = "none")


# what is the sampling interval? 
wildschwein <- wildschwein %>%
  group_by(TierID,CollarID)%>%
  mutate(
    timediffS = as.integer(difftime(lead(DatetimeUTC),DatetimeUTC,units = "secs"))
  )

p <- ggplot(wildschwein, aes(timediffS))+
  geom_histogram(binwidth = 10,colour = "black",fill = "white") +
  lims(x = c(0,10*60)) +
  scale_y_continuous(trans = log_trans(), breaks = base_breaks(),labels = prettyNum)

ggplotly(p)




wildschwein %>%
  mutate(
    hour = hour(DatetimeUTC),
    minute = minute(DatetimeUTC),
    hourDec = as.numeric(hour) + as.numeric(minute)/60
  ) %>%
  ggplot(aes(hourDec)) +
  geom_histogram(binwidth = 0.01, fill = "white",colour = "black") +
  lims(x = c(0,01))


wildschwein <- wildschwein %>%
  group_by(TierID,CollarID) %>%
  mutate(
    timediffM = timediffS/60,
    group = cut(timediffM,breaks = c(0,2,50,100,150,200)),
    groupSeq = group == lead(group)
  ) %>%
  ungroup() %>%
  mutate(
    groupSeq = number_groups(groupSeq,include_next = T)
  )


wildschwein %>%
  group_by(TierID,CollarID,groupSeq) %>%
  filter(group == "(0,2]") %>%
  filter(!is.na(groupSeq)) %>%
  mutate(
    steplength1 = euclid(X,Y,lead(X,1),lead(Y,1)),
    timediff1 = as.integer(difftime(lead(DatetimeUTC,1),DatetimeUTC,unit = "secs")),
    speed1 = steplength1/timediff1,
    steplength10 = euclid(X,Y,lead(X,10),lead(Y,10)),
    timediff10 = as.integer(difftime(lead(DatetimeUTC,10),DatetimeUTC,unit = "secs")),
    speed10 = steplength10/timediff10,
    steplength2 = euclid(X,Y,lead(X,2),lead(Y,2)),
    timediff2 = as.integer(difftime(lead(DatetimeUTC,2),DatetimeUTC,unit = "secs")),
    speed2 = steplength2/timediff2,
    steplength3 = euclid(X,Y,lead(X,3),lead(Y,3)),
    timediff3 = as.integer(difftime(lead(DatetimeUTC,3),DatetimeUTC,unit = "secs")),
    speed3 = steplength3/timediff3,
    steplength5 = euclid(X,Y,lead(X,5),lead(Y,5)),
    timediff5 = as.integer(difftime(lead(DatetimeUTC,5),DatetimeUTC,unit = "secs")),
    speed5 = steplength5/timediff5
  ) %>%
  gather(key,timediff,c(timediff1,timediff2,timediff3,timediff5,timediff10)) %>%
  gather(key,speed, c(speed1,speed2,speed3,speed5,speed10)) %>%
  select(-key) %>%
  ggplot(aes(timediff,speed, group = timediff)) +
  geom_boxplot()



wildschwein %>%
  group_by(TierID,CollarID) %>%
  mutate(
    timediffM = timediffS/60,
    date = date(DatetimeUTC),
    dayNr = difftime(date,min(date),units = "days")
  )
  filter(TierID == "015",dayNr %in% 0:50) %>%
  filter(!is.na(groupSeq)) %>%
  # slice(1:200) %>%
  ggplot(aes(DatetimeUTC,timediffM, colour = as.factor(groupSeq))) +
  geom_line() +
  geom_point() +
  scale_y_continuous(breaks = seq(0,200,10))+
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")


wildschwein %>%
  group_by(TierID,CollarID) %>%
  mutate(
    timediffM = timediffS/60,
    date = date(DatetimeUTC),
    dayNr = difftime(date,min(date),units = "days"),
    samplegr = timediffM>120
  ) %>%
  filter(TierID == "015",dayNr %in% 15:16) %>%
  ggplot(aes(X,Y,colour = samplegr)) +
  geom_point() +
  geom_path()




# Leaflet 
factpal <- colorFactor(topo.colors(length(levels(cp@data$id))), cp@data$id))

leaflet(cp) %>%
  addPolygons(popup = paste("ID: ",cp@data$id), color = ~factpal(cp@data$id)) %>%
  addTiles()




# 
# wildschwein %>%
#   # filter(TierID == "015") %>%
#   mutate(timediff = as.numeric(difftime(DatetimeUTC,lag(DatetimeUTC),units = "mins"))) %>%
#   # dplyr::select(timediff) %>%
#   ggplot(aes(timediff)) +
#   geom_histogram(binwidth = 1,fill = "grey", colour= "blue") +
#   scale_y_log10() +
#   facet_wrap(~TierID)
# 
# wildschwein %>%
#   mutate(
#     timediffMins = as.integer(timediffSecs/60)
#     ) %>%
#   group_by(TierID,timediffMins) %>%
#   summarise(n = n()) %>%
#   ggplot(aes(timediffMins,n)) +
#   geom_point()
# 
# 
# 
# 
# ggplot(wildschwein, aes(timediffSecs,speedMS, colour = TierID)) +
#   geom_point() +
#   scale_x_continuous(limits = c(0,500)) +
#   facet_wrap(~TierID)

# wildschwein %>%
#   filter(TierID == "039") %>%
#   ggplot(aes(timediffSecs,speedMS, colour = TierID)) +
#   geom_point() +
#   scale_x_continuous(limits = c(0,500)) +
#   facet_wrap(~TierID)


#############################################################################
## Lesson 3 #################################################################
#############################################################################

# - Matt's students package
# - Compute similarities between trajectories (similarity measure from leiden workshop?!)
# 
# Introduction of Rmarkdown for Project?


#############################################################################
## Lesson 4 #################################################################
#############################################################################
# - Operationalize and find meet patterns 
# - Visualize spatial distribution of meet
# - Define functions


#############################################################################
## Lesson 5 #################################################################
#############################################################################
# - enrich trajectories with R (overlay)
# - attach context (land-use, slope) to trajectories, 
# - search for correlations (speed vs. slope, speed vs. landUse). BSc Tomlinson
# - Mapmatching MTB tracks on paths
# - Area centered analysis (MCP, DU, KDE, home range)
