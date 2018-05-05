

test <- read_lines("W01_01_Exercise.R")



head(test)
headers <- stringi::stri_detect(test, regex = "#' ###")
other_text <- stringi::stri_detect(test, regex = "#'")

head(test[!(other_text & !headers)],10)
