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
