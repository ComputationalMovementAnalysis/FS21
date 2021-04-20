knitr::opts_chunk$set(echo = FALSE, include = FALSE, eval = TRUE, purl = TRUE, collapse = TRUE, warning = FALSE, message = FALSE)

# Store coordinates in a new variable

coordinates <- st_coordinates(wildschwein_BE)

head(coordinates)

colnames(coordinates) <- c("E","N")

wildschwein_BE <- cbind(wildschwein_BE,coordinates)

head(wildschwein_BE)

#- chunkend

now <- Sys.time()

later <- now + 10000

time_difference <- difftime(later,now)

knitr::include_graphics("02_Images/laube_2011_2.jpg")

time_difference

nrow(caro60)
nrow(caro60_3)
nrow(caro60_6)
nrow(caro60_9)

numbers <- 1:10

numbers

library(zoo)

example <- rnorm(10)
rollmean(example,k = 3,fill = NA,align = "left")
rollmean(example,k = 4,fill = NA,align = "left")




wildschwein_BE$timelag  <- as.numeric(difftime(lead(wildschwein_BE$DatetimeUTC),
                                               wildschwein_BE$DatetimeUTC,
                                               units = "secs"))


wildschwein_BE <- mutate(wildschwein_BE,timelag = as.numeric(difftime(lead(DatetimeUTC),
                                                                      DatetimeUTC,
                                                                      units = "secs")))
