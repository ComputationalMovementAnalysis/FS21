
library(tidyverse)
library(lubridate)
library(leaflet)
library(sp)
library(adehabitatHR)
library(scales)
library(plotly)
library(sf)
library(purrr)

euclid <- function(x1,y1,x2,y2){
  return(sqrt((x1-x2)^2+(y1-y2)^2)) 
}



as.ggPolygon <- function(SpatialPolygonDataframe){
  SpatialPolygonDataframe$data$id <- rownames(SpatialPolygonDataframe@data)
  fortified <- fortify(SpatialPolygonDataframe, region = "id")
  merged <- merge(fortified,SpatialPolygonDataframe@data, by = "id")
  return(merged)
}


MCP_df <- function(dataframe,animalID,Lat,Long,percent = 95,output = "ggplot"){
  lapply(c("sp","adehabitatHR","tidyverse"), require, character.only = TRUE)
  SpatialPolygonDataframe <- SpatialPointsDataFrame(dataframe[,c(Lat,Long)],dataframe)
  cp <- mcp(SpatialPolygonDataframe[,animalID],percent = percent)
  if(!(output %in% c("ggplot","spdf"))) stop("Argument 'output' must be either 'ggplot' or 'spdf'")
  if(output == "ggplot"){
    cp <- as.ggPolygon(cp)
    print("output created for ggplot")
  } else if(output == "spdf"){
    print("output returend as 'SpatialPointsDataFrame' (spdf)")
  } else("something went seriously wrong!")
  return(cp)
}


number_groups <- function(input,include_next = F){
  input[is.na(input)] <- FALSE 
  group = head(cumsum(c(TRUE,!input)),-1)
  if(include_next == F){
    group[!input] <- NA
  } else{
    compare <- head(group,-1) == tail(group,-1)
    uniques <- !(c(compare,F) | c(F,compare))
    group[which(uniques)] <- NA
  } 
  group <- as.factor(group)
  levels(group) <- 1:length(levels(group))
  return(group)
}


base_breaks <- function(n = 10){
  function(x) {
    axisTicks(log10(range(x, na.rm = TRUE)), log = TRUE, n = n)
  }
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

wildschwein <- dplyr::select(wildschwein, Tier,DatumUTC,ZeitUTC,Lat,Long)
wildschwein <- separate(wildschwein, Tier,into = c("TierID","TierName","CollarID"))
wildschwein <- mutate(wildschwein, DatetimeUTC = parse_datetime(paste(DatumUTC,ZeitUTC),format = "%d.%m.%Y %H:%M:%S", locale = locale(tz = "UTC")))


wildschwein <- select(wildschwein, -DatumUTC,-ZeitUTC)

# Visualize Points via. lat/long. Note: lat/long are plotted as cartesian coordinates
ggplot(wildschwein, aes(Long,Lat, colour = TierID)) +
  geom_point() +
  coord_fixed(1)


# turn df into sf-object
wildschwein_sf = st_as_sf(wildschwein, coords = c("Long", "Lat"), crs = 4326, agr = "constant")

# Transform coordinate system
wildschwein_sf <- st_transform(wildschwein_sf, 2056)

# calculate MCP for each individual (prepare as function)
mcp95 <- wildschwein_sf2056 %>%
  select(TierID) %>%
  as("Spatial") %>%
  mcp(95)%>%
  st_as_sf() %>%
  st_set_crs(st_crs(wildschwein_sf2056))

ggplot(mcp95) +
  geom_sf(aes(fill = id), alpha = 0.3) +
  coord_sf(datum = 2056) + 
  theme(
    legend.position = "none",
    panel.grid.major = element_line(colour = "transparent"),
    panel.background = element_rect(fill = "transparent")
    )



# find which MPCs overlap (maby illustrate this with map()?)
overlap <- matrix(nrow = nrow(mcp95),ncol = nrow(mcp95))
for(feature in 1:nrow(mcp95)){
  overlap[feature,] <- st_intersects(mcp95[feature,],mcp95,sparse = F)
}
overlap[lower.tri(overlap,T)] <- NA

rownames(overlap) <- mcp95$id
colnames(overlap) <- mcp95$id

# Trying to find overlapping time windows:
overlap_temporal <- wildschwein %>%
  group_by(TierID) %>%
  summarise(
    min = min(DatetimeUTC,na.rm = T),
    max = max(DatetimeUTC,na.rm = T)
  ) %>%
  ungroup() %>%
  mutate(
    interval = interval(min,max)
  )

overlap_temporal_mat <- matrix(nrow = nrow(overlap_temporal),ncol = nrow(overlap_temporal))
for(row_i in 1:nrow(overlap_temporal)){
  for(col_i in 1:nrow(overlap_temporal)){
    overlap_temporal_mat[row_i,col_i] <- lubridate::int_overlaps(overlap_temporal$interval[row_i,],overlap_temporal$interval[col_i,])
  }
}
overlap_temporal_mat[lower.tri(overlap_temporal_mat,T)] <- NA

rownames(overlap_temporal_mat) <- overlap_temporal$TierID
colnames(overlap_temporal_mat) <- overlap_temporal$TierID


overlap_spat_temp <- overlap_temporal_mat & overlap

as.data.frame(overlap_spat_temp) %>%
  rownames_to_column("id1") %>%
  gather(id2,bool,-id1) %>%
  filter(bool == TRUE) %>%
  select(-bool)

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
