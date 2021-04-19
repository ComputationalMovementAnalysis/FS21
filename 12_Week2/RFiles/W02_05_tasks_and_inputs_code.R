knitr::opts_chunk$set(echo = FALSE, include = FALSE, eval = TRUE, purl = TRUE, collapse = TRUE, warning = FALSE, message = FALSE)

# Store coordinates in a new variable

coordinates <- st_coordinates(wildschwein_BE)

head(coordinates)

colnames(coordinates) <- c("E","N")

wildschwein_BE <- cbind(wildschwein_BE,coordinates)

head(wildschwein_BE)

#- chunkend



knitr::include_graphics("02_Images/laube_2011_2.jpg")


library(sf)

wildschwein_BE_sf <- st_as_sf(wildschwein_BE, 
                              coords = c("Long", "Lat"), 
                              crs = 4326)


nrow(caro60)
nrow(caro60_3)
nrow(caro60_6)
nrow(caro60_9)

# subset rows
wildschwein_BE_sf[1:10,]
wildschwein_BE_sf[wildschwein_BE_sf$TierName == "Sabi",]

# subset colums
wildschwein_BE_sf[,2:3]

library(zoo)

example <- rnorm(10)
rollmean(example,k = 3,fill = NA,align = "left")
rollmean(example,k = 4,fill = NA,align = "left")



wildschwein_BE


wildschwein_BE_grouped <- group_by(wildschwein_BE,TierID)

wildschwein_BE_grouped

