---
title: "Computational Movement Analysis: Patterns and Trends in Environmental Data"
subtitle: "Master ENR, Spring Semester 2021"
author: "Patrick Laube, Nils Ratnaweera, Nikolaos Bakogiannis"
date: "07 May, 2021"
site: bookdown::bookdown_site
documentclass: book
bibliography: ["00_Admin/bibliography.bib"]
link-citations: true
github-repo: ComputationalMovementAnalysis/FS21
---





```r

library(stringr)
library(dplyr)
library(purrr)

get_mod_age <- function(files, now){
  difftime(now,file.info(files)$mtime)
}

now <- Sys.time()
rfiles <- list.files(pattern = "\\.R$", recursive = TRUE)

encrypted = rfiles[grepl("^\\d{2}_Week\\d/solutions/task_\\d\\.R$",rfiles)]
decrypted = rfiles[grepl("^\\d{2}_Week\\d/solutions/task_\\d\\_hide.R$",rfiles)]

encrypted_df <- tibble::tibble(encrypted = encrypted, key = str_sub(encrypted, end = -3))
decrypted_df <- tibble::tibble(decrypted = decrypted, key = str_sub(decrypted, end = -8))

solutions <- full_join(encrypted_df, decrypted_df, by = "key") %>% 
  mutate(
    encrypted_age = get_mod_age(encrypted, now),
    decrypted_age = get_mod_age(decrypted, now)
    )


library(magrittr)
library(purrr)
solutions %>%
  mutate(
    encrypt = decrypted_age < encrypted_age | is.na(encrypted)
  ) %>%
  dplyr::select(encrypted, decrypted,encrypt) %>% 
  pmap(function(encrypted, decrypted,encrypt){
    if(encrypt){
      myencrypt(decrypted,".passphrase")
    } else{
      mydecrypt(encrypted, ".passphrase",TRUE)
    }
  })
## [1] "11_Week1/solutions/task_2.R"
## [1] "11_Week1/solutions/task_3.R"
## [1] "11_Week1/solutions/task_4.R"
## [1] "11_Week1/solutions/task_5.R"
## [1] "11_Week1/solutions/task_6.R"
## [1] "12_Week2/solutions/task_0.R"
## [1] "12_Week2/solutions/task_1.R"
## [1] "12_Week2/solutions/task_2.R"
## [1] "12_Week2/solutions/task_3.R"
## [1] "12_Week2/solutions/task_4.R"
## [1] "13_Week3/solutions/task_1.R"
## [1] "13_Week3/solutions/task_2.R"
## [1] "13_Week3/solutions/task_3.R"
## [1] "13_Week3/solutions/task_4.R"
## [1] "13_Week3/solutions/task_5.R"
## [1] "13_Week3/solutions/task_6.R"
## [1] "14_Week4/solutions/task_1.R"
## [1] "14_Week4/solutions/task_2.R"
## [1] "14_Week4/solutions/task_3.R"
## [1] "14_Week4/solutions/task_4.R"
## [1] "14_Week4/solutions/task_5.R"
## [1] "14_Week4/solutions/task_6.R"
## [1] "15_Week5/solutions/task_1.R"
## [1] "15_Week5/solutions/task_2.R"
## [1] "15_Week5/solutions/task_4.R"
## [[1]]
## NULL
## 
## [[2]]
## [1] "11_Week1/solutions/task_2.R"
## 
## [[3]]
## [1] "11_Week1/solutions/task_3.R"
## 
## [[4]]
## [1] "11_Week1/solutions/task_4.R"
## 
## [[5]]
## [1] "11_Week1/solutions/task_5.R"
## 
## [[6]]
## [1] "11_Week1/solutions/task_6.R"
## 
## [[7]]
## [1] "12_Week2/solutions/task_0.R"
## 
## [[8]]
## [1] "12_Week2/solutions/task_1.R"
## 
## [[9]]
## [1] "12_Week2/solutions/task_2.R"
## 
## [[10]]
## [1] "12_Week2/solutions/task_3.R"
## 
## [[11]]
## [1] "12_Week2/solutions/task_4.R"
## 
## [[12]]
## [1] "13_Week3/solutions/task_1.R"
## 
## [[13]]
## [1] "13_Week3/solutions/task_2.R"
## 
## [[14]]
## [1] "13_Week3/solutions/task_3.R"
## 
## [[15]]
## [1] "13_Week3/solutions/task_4.R"
## 
## [[16]]
## [1] "13_Week3/solutions/task_5.R"
## 
## [[17]]
## [1] "13_Week3/solutions/task_6.R"
## 
## [[18]]
## [1] "14_Week4/solutions/task_1.R"
## 
## [[19]]
## [1] "14_Week4/solutions/task_2.R"
## 
## [[20]]
## [1] "14_Week4/solutions/task_3.R"
## 
## [[21]]
## [1] "14_Week4/solutions/task_4.R"
## 
## [[22]]
## [1] "14_Week4/solutions/task_5.R"
## 
## [[23]]
## [1] "14_Week4/solutions/task_6.R"
## 
## [[24]]
## [1] "15_Week5/solutions/task_1.R"
## 
## [[25]]
## [1] "15_Week5/solutions/task_2.R"
## 
## [[26]]
## [1] "15_Week5/solutions/task_4.R"
```



# Welcome to the course! {-}

For the practical part of the course, building-up skills for analyzing movement data in the software environment `R`, you'll be using data from the ZHAW project ["Prävention von Wildschweinschäden in der Landwirtschaft"](https://www.zhaw.ch/de/ueber-uns/aktuell/news/detailansicht-news/event-news/wildschweinschaeden-mit-akustischer-methode-verhindern/).

The project investigates the spatiotemporal movement patterns of wild boar (*Sus scrofa*) in agricultural landscapes. We will study the trajectories of these wild boar, practising the most basic analysis tasks of Computational Movement Analysis (CMA). 


<div style="position: relative; width: 100%; height: 0; padding-bottom: 56.25%;"> <iframe src="//www.youtube.com/embed/WYXnCQMfPiI" frameborder="0" allowfullscreen style = "position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe> </div><caption>This video gives a nice introduction into the project</caption>


# License {-}


These R Exercises are created by Patrick Laube, Nils Ratnaweera and Nikolaos Bakogiannis for the Course *Computational Movement Analysis" and are licensed under [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).


<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.

<!-- **Please note:** we are given application data from an ongoing research project. Capturing wild living animals and then equipping them with GPS collars is a very labor and cost intensive form of research. Consequently, data resulting such campaigns is a very valuable asset that must be protected. So, please do not pass on this data, for any use beyond this module contact Patrick Laube or the data owner Stefan Suter (suts@zhaw.ch). -->



