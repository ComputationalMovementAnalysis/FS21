knitr::opts_chunk$set(echo = FALSE, include = FALSE, eval = TRUE, purl = TRUE, collapse = TRUE, warning = FALSE, message = FALSE)

# Store coordinates in a new variable

coordinates <- st_coordinates(wildschwein_BE)

head(coordinates)

colnames(coordinates) <- c("E","N")

wildschwein_BE <- cbind(wildschwein_BE,coordinates)

head(wildschwein_BE)

#- chunkend

rootdir <- "C:/Users/yourname/semester2/Modul_CMA"

paths2node <- function(paths){
  require(data.tree)
  as.Node(data.frame(paths = paths),pathName = "paths")
}

subpaths <- function(rootfolder_path, rootfolder_name, subfolders){
  require(stringr)
  c(paste0(rootfolder_name," (",stringr::str_replace_all(rootfolder_path, "/", "\\\\"),")"), file.path("rootfolder_path",subfolders))
}


knitr::include_graphics("02_Images/laube_2011_2.jpg")



nrow(caro60)
nrow(caro60_3)
nrow(caro60_6)
nrow(caro60_9)



library(zoo)

example <- rnorm(10)
rollmean(example,k = 3,fill = NA,align = "left")
rollmean(example,k = 4,fill = NA,align = "left")


