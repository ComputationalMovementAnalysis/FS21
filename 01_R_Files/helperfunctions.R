mydecrypt <- function(file_encrypted,seedfile, write = FALSE){
  require(stringr)
  
  rl_scrambled <- readLines(file_encrypted,warn = FALSE)
  
  seed <- as.integer(readLines(seedfile,warn = FALSE))
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
  
  seed <- as.integer(readLines(seedfile,warn = FALSE))
  
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

