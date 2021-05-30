mydecrypt <- function(file_encrypted, seedfile, write = FALSE){
  require(stringr)
  
  rl_scrambled <- readLines(file_encrypted,warn = FALSE)
  
  if(is.numeric(seedfile)){
    seed <- seedfile
  } else{
    seed <- as.integer(readLines(seedfile,warn = FALSE))
  }
  
  # seed = 1
  unscramble <- function(l){
    
    set.seed(seed)
    letters_rand <- sample(letters,length(letters),replace = FALSE)
    letters[match(l,letters_rand)]
  }
  
  
  rl <- stringr::str_replace_all(rl_scrambled,paste(letters,collapse = "|"),unscramble)
  
  if(write){
    writeLines(rl,stringr::str_replace(file_encrypted,"\\.R","_hide.R"))
  } else{
    return(rl)
  }
}

myencrypt <- function(file_plain,seedfile){
  rl <- readLines(file_plain,warn = FALSE)
  
  if(is.numeric(seedfile)){
    seed <- seedfile
  } else{
    seed <- as.integer(readLines(seedfile,warn = FALSE))
  }
  
  scramble <- function(l){
    
    set.seed(seed)
    letters_rand <- sample(letters,length(letters),replace = FALSE)
    letters_rand[match(l,letters)]
  }
  
  rl_scrambled <- stringr::str_replace_all(rl,paste(letters,collapse = "|"),scramble)
  
  newname <- stringr::str_remove(file_plain,"_hide")
  writeLines(rl_scrambled,newname)
  print(newname)
  
}


youtube <- function(id, text = "", thumbnailfolder = NA, selfcontained = TRUE){
  require(knitr)
  require(glue)
  # If selfcontained = FALSE, you must set the css accordingly (.container and .video)
  # https://www.h3xed.com/web-development/how-to-make-a-responsive-100-width-youtube-iframe-embed
  # .container {
  #     position: relative;
  #     width: 100%;
  #     height: 0;
  #     padding-bottom: 56.25%;
  # }
  # .video {
  #     position: absolute;
  #     top: 0;
  #     left: 0;
  #     width: 100%;
  #     height: 100%;
  # }
  
  css_container <- "position: relative; width: 100%; height: 0; padding-bottom: 56.25%;"
  css_video <- "position: absolute; top: 0; left: 0; width: 100%; height: 100%;"
  
  if(knitr::is_html_output()){
    if(selfcontained){
      glue::glue('<div style="{css_container}"> <iframe src="//www.youtube.com/embed/{id}" frameborder="0" allowfullscreen style = "{css_video}"></iframe> </div><caption>{text}</caption>')
    } else{
      glue::glue('<div class="container"> <iframe src="//www.youtube.com/embed/{id}" frameborder="0" allowfullscreen class="video"></iframe> </div><caption class = "caption">{text}</caption>')
    }
  } else{
    thumbnail <- glue("{thumbnailfolder}/{id}.jpg")
    if(!file.exists(thumbnail)){
      download.file(glue("https://img.youtube.com/vi/{id}/0.jpg"),thumbnail, mode = 'wb')
    }
    
    cat("\\begin{figure}[hbt!]",
        "\\centering",
        paste0("\\includegraphics{",thumbnail,"}"),
        paste0("\\caption{Der Video ist in voller Länge hier abgespeichert: \\url{https://youtu.be/",id,"}}"),
        "\\end{figure}")
  }
}


# Gets the URL to the github repo
get_yaml <- function(what,bookdown_yaml = "_bookdown.yml") {
  require(yaml)
  yaml::read_yaml(bookdown_yaml)[[what]]
}
# Turns the "edit" url into a "raw" url

get_github <- function(type,bookdown_yaml = "_bookdown.yml"){
  require(stringr)
  require(yaml)
  github_edit <- get_yaml("edit")
  str_remove(stringr::str_replace(github_edit, "/edit/",paste0("/",type,"/")),"%s")
}

# given a filename, a folder and a github_url (raw) it returns an url that allows downloading said file
download_url <- function(filename,folder){
  require(glue)
  github_raw <- get_github("raw")
  glue("[{filename}]({github_raw}{folder}/{filename})")
}


# Given a path containing R-files containing solution to tasks, this function grabs 
# all these R files and prints out the code as a character vector. 
# There are a couple of assumptions that I hope hold true in the weeks and years (!)
# to come:
# - the regex to grab the R-files is \d\.R, so as to exclude files ending with _hide.R
# - the filename of the R-file can be used as comment to describe the code (after)
#   some cleanup)
# This function is to be used in combination with a code chunk
# ```{r code =  solutions_print("11_Week1/",".passphrase"), , opts.label="solution_print"}
# ```
solutions_print <- function(solutionspath, seedfile){
  require(stringr)
  require(magrittr)
  require(purrr)
  list.files(solutionspath,"\\d\\.R",full.names = TRUE) %>%
    map(function(path){
      taskname <- paste("#", str_replace(str_remove(basename(path), ".R"), "_", " ")) %>%
        paste(., paste(rep("#",80-str_length(.)),collapse = ""))
      
      mydecrypt(path,seedfile) %>% c("", taskname,"",.,"")
    }) %>%
    unlist()
}

# Given a Rmdfile, this function returns a purl-ed version of the file by extracting
# the code chunks and returning them as a character vector. Its very similar to 
# knitr::purl, with the difference that you dont have any documentation option and
# that the output does not produce intermediate (R-) files. It is to be used in
# combination with a code chunk, like so:
# ```{r code =  purl_quick("12_Week2/W02_04_demo_tidyverse.Rmd"), echo = TRUE, eval = FALSE}
# ``
purl_quick <- function(inputfile){
  require(stringr)
  mylines <- readLines(inputfile,warn = FALSE)
  chunkboders <- str_starts(mylines, "```")
  cumsum <- cumsum(chunkboders)
  inchunk <- cumsum %% 2 == 1 & !chunkboders
  
  
  mylines[inchunk]
}

# Some additional stuff added so the whole workflow complies with the K-M approach
week_folders <- paste0("week",1:7)

reponame <- paste("cma",week_folders[2], sep = "-")
repourl <- paste0("https://github.com/YOUR-GITHUB-USERNAME/",reponame)
repourl_git <- paste0(repourl, ".git")

paths2node <- function(paths){
  require(data.tree)
  as.Node(data.frame(paths = paths),pathName = "paths")
}

subpaths <- function(rootfolder_path, rootfolder_name, subfolders){
  require(stringr)
  c(paste0(rootfolder_name," (",stringr::str_replace_all(rootfolder_path, "/", "\\\\"),")"), file.path("rootfolder_path",subfolders))
}


## Templates for chunk outputs
knitr::opts_chunk$set(collapse = TRUE, warning = FALSE, message = FALSE)

knitr::opts_template$set(
  solution_showOutput = list(echo = FALSE),
  solution_hideOutput = list(echo = FALSE, include = FALSE),
  example_showOutput = list(echo = TRUE),
  example_hideOutput = list(echo = TRUE, results = "hide")
)


get_mod_age <- function(files, now){
  difftime(now,file.info(files)$mtime)
}
