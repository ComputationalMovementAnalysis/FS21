## Task 1 ######################################################################

source("01_R_Files/helperfunctions.R")

#- chunkend

## Task 2 ######################################################################

rootdir <- "C:/Users/yourname/semester2/Modul_CMA"

paths2node <- function(paths){
  require(data.tree)
  as.Node(data.frame(paths = paths),pathName = "paths")
}

subpaths <- function(rootfolder_path, rootfolder_name, subfolders){
  require(stringr)
  c(paste0(rootfolder_name," (",stringr::str_replace_all(rootfolder_path, "/", "\\\\"),")"), file.path("rootfolder_path",subfolders))
}


## Task 4 ######################################################################
