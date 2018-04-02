# Allow duplicate Labels so that calling purl() does not create an error
# https://stackoverflow.com/q/36868287/4139249
# options(knitr.duplicate.label = 'allow')

# purl all Rmd Documents (with some exceptions) and store them in a Subfolder /RFiles
# Document cannot be knitted if the folder "RFiles" does not exist!
library(stringr)

rmds <- list.files(pattern = ".Rmd",recursive = T)

exclude <- c("_Rcode","99_","index","Archive","Admin","_main","project_ideas")

rmds <- rmds[-grep(paste(exclude,collapse="|"), rmds, value=F)]


for (file in rmds){
  file_r <- gsub("Rmd","R",file)              # change fileextension from .rmd to r
  file_r <- str_split_fixed(file_r,"/",Inf)   # split path at /
  file_r <- append(file_r, "RFiles",length(file_r)-1)# append Foldername "RFiles" in 2nd last pos
  file_r <- paste(file_r,collapse = "/")    # collapse vector to string
  if(file.exists(file_r)){
    file.remove(file_r)
  }
  # print(file)
  knitr::purl(file,documentation = 0,output = file_r)
}
