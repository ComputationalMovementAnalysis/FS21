---
title: "Computational Movement Analysis: Patterns and Trends in Environmental Data"
subtitle: "Master ENR, Spring Semester 2021"
author: "Patrick Laube, Nils Ratnaweera, Nikolaos Bakogiannis"
date: "20 May, 2021"
site: bookdown::bookdown_site
documentclass: book
bibliography: ["00_Admin/bibliography.bib"]
link-citations: true
github-repo: ComputationalMovementAnalysis/FS21
---








# Welcome to the course! {-}

For the practical part of the course, building-up skills for analyzing movement data in the software environment `R`, you'll be using data from the ZHAW project ["Prävention von Wildschweinschäden in der Landwirtschaft"](https://www.zhaw.ch/de/ueber-uns/aktuell/news/detailansicht-news/event-news/wildschweinschaeden-mit-akustischer-methode-verhindern/).

The project investigates the spatiotemporal movement patterns of wild boar (*Sus scrofa*) in agricultural landscapes. We will study the trajectories of these wild boar, practising the most basic analysis tasks of Computational Movement Analysis (CMA). 


<div style="position: relative; width: 100%; height: 0; padding-bottom: 56.25%;"> <iframe src="//www.youtube.com/embed/WYXnCQMfPiI" frameborder="0" allowfullscreen style = "position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe> </div><caption>This video gives a nice introduction into the project</caption>


# License {-}


These R Exercises are created by Patrick Laube, Nils Ratnaweera and Nikolaos Bakogiannis for the Course *Computational Movement Analysis" and are licensed under [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).


<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.

<!--chapter:end:index.Rmd-->

# Exercise 4


**Learning Outcomes***

- You are able to conceptualize a simple movement pattern and implement data structures and corresponding procedures (let's call them algorithms...) for detecting it using R.
- You understand the sensitivity of movement patterns to pattern parameter thresholds.


**Prerequisites***

- Readings Skills from "R for Data Science" [@wickham2017]: RS4.1 Chap15 Functions (19p, 269-289)
- Readings Theory, @laube2014: R4.1 Chap.2, p. 29-58


<!--chapter:end:W04_01_exercise.Rmd-->

## Peer Feedback



This weeks exercises are not mandatory. However, we recommend you submit your solutions none the less and give each other peer feedback similar to how you received feedback from us in week 2. If you would like to receive peer feedback on your exercise, provide the URL to your repo in the comment section at the bottom of this page. 

If you would like to provide peer feedback, reply to such a post accordingly. Then, to get the repo of your fellow student on your local hard drive you can use the Github URL and create a new RStudio in the following manner:

1. In RStudio, start a new project
2. Choose: File > New Project > Version Control > Git.
3. In the repository URL, paste the URL from your peer

This will create a clone of that project on your local machine and open it in RStudio. You can then run and inspect the code of your peer and provide feedback using issues(in the way we provided feedback in week 2). In issues you can reference specific lines of code, similar like the *comment* feature in Microsoft Word. You have two ways to reference of specific line(s):

1. via [the browser (on github.com)](#issues-option1): This requires no initial set up and is quite straightforward. However, you will need to switch back and forth between RStudio and Github, which can be quite tiresome. 
2. via [our RStudio Addin](#issues-option2): this will require 10 minutes of set up, but should be faster to use afterwards. We therefore recommend this option, however: We developed this addin ourselves and it might not be stable for everyone. Please contact us if it does not work for you.

### Option 1: via the browser on github.com {#issues-option1}

1. Open the repo's URL in your browser
2. Find and open the R / RMarkdown script containing the code you want to provide feedback on
3. Highlight the lines you want to reference by clicking on the respective line numbers (you can select multiple lines by selecting the first line, holding the shift key and then selecting the last line)
4. Click on the three dots situatied to the left of the first line
5. Choose *Reference in new issue*. This will create a new issue with a link referencing the specific lines.
6. Add your comment
  
![](https://github.blog/wp-content/uploads/2017/08/29093044-6477ba12-7c56-11e7-9bd2-e6db926d70be.gif?resize=1360%2C600)


### Option 2: via our RStudio addin {#issues-option2}

One time setup:

1. Install `devtools` (`install.packages("devtools")`)
2. Install `inlineComments` [from Github](github.com/ratnanil/inlineComments) (`devtools::install_github("ratnanil/inlineComments")`)
4. Restart RStudio
5. Click on *tools > Modify keyboard shortcuts* and add a shortcut for the command *Insert inline comment* (e.g. `Ctrl + Shift + k`) 

Now for each comment, you can highlight the lines you wish to comment and use the keyboard shortcut you assigned in the last step (e.g. `Ctrl + Shift + k`). This should open a window where you can add your comment and if you hit *Create issue*, your comments will be added to your fellow student's repo and a message will show you a link to the new issue.


<!--chapter:end:W04_05_peer_feedback.Rmd-->

# References {-}

<!--chapter:end:90_references.Rmd-->

