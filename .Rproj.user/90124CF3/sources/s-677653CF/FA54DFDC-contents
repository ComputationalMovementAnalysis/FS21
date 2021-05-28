

library(tidyverse)
fi <- list.files(pattern = "tasks_and_inputs.Rmd", recursive = TRUE)

get_task_headers <- function(rmd_file){
  line <- readLines(rmd_file)
  
  chunkborder <- str_starts(line, "```")
  
  cumsums <- cumsum(chunkborder)
  
  inchunk <- cumsums %% 2 == 1 | chunkborder
  
  lines2 <- line[!inchunk]
  
  lines2[str_detect(lines2, "### Task")]
}





imap(setNames(fi, str_remove(dirname(fi), "\\d{2}_")), function(file,week){
  headers <- get_task_headers(file)
  
  unlist(map(headers, ~c(.x, "","```{r}","", "```", ""))) %>%
    write_lines(file = file.path("00_Admin/Tasks_template",paste0(week, ".Rmd")))
})

  