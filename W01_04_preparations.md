## Preparation {#w1-preparation}

Much of this chapter was taken from @bryan2021. If you want to dive deeper into using Git, we highly recommend this book. For an *even* deeper dive into Git, read @chacon2014. Both books are available free and open source on [happygitwithr.com](https://happygitwithr.com/) and [git-scm.com/book](https://git-scm.com/book/), respectively. 







### Check you version of `R`

Check your Version of `R` by opening RStudio and typing the following command into the console. 


```r
R.version.string
## [1] "R version 4.0.3 (2020-10-10)"
```

This returns the version number of your R installation, whereas the first digit (`4`) indicates the number of the *major release*, the second digit  (`0`) indicates the *minor release* and the last digit (`3`) refers to the *patch release*. As a general rule of thumb, you will want to update R if you

- don't have the current *major* version or
- are lagging two (or more) versions behind the current *minor release*

In the time of writing (May, 2021), the current `R` Version is 4.1.0 (released on 2021-05-18 07:05:22, see [cran.r-project.org](https://cran.r-project.org/)). Your installation should therefore not be older than 4.0.0. If it is, make sure that you have updated R until next week (doing it now will probably take too long). Check [these instructions on how to update R](https://www.linkedin.com/pulse/3-methods-update-r-rstudio-windows-mac-woratana-ngarmtrakulchol/)


### Check your version of RStudio

RStudio is the Graphical User Interface (GUI) we use in our course to interact with R. RStudio should not be too old either and we recommend updating if you don't have the latest version: check if this is the case by clicking on *help > check for updates*. If you need to update RStudio, don't update now but have a newer version of RStudio installed before next week. 


### Install the necessary packages

If you haven't already, install the packages `tidyverse`, `sf` and `terra`(using `install.packages()`). 


```r
install.packages("tidyverse")
install.packages("sf")
install.packages("terra")
```


### Install Git{#install-git}

Next, install Git. There are different Git installers to choose from, we recommend the following:

<!-- If you are not sure whether you already have Git installed or not, you can verify this by typing `git --version` in the terminal. If this command returns a version number you have Git installed already and might only need to update it. If this command returns `git: command not found` (or something similar), you will need to install Git first. -->


- **Windows**: 
  - We recommend installing [Git for Windows](https://gitforwindows.org/), also known as `msysgit` or “Git Bash". 
  - When asked about “Adjusting your PATH environment”, select “Git from the command line and also from 3rd-party software”
  - RStudio prefers Git to be installed in `C:/Program Files/Git`, we recommend following this convention
  - Otherwise, we believe it is good to accept the defaults
- **macOS**:  
  - We recommend you install the Xcode command line tools (not all of Xcode), which includes Git
  - Go to the shell and enter `xcode-select --install` to install developer command line tools
- **Linux**: 
  - On Ubuntu or Debian Linux: `sudo apt-get install git`
  - On Fedora or RedHat Linux: `sudo yum install git`
  


### Configure RStudio{#configure-rstudio}

Now we will set some RStudio Global options. But first, **close all instances of RStudio and restart it (!!!)**. Then go to Tools > Global options. 

- **R General**
  - Deactivate the option "Restore .RData into workspace at startup"[^restore]
  - Set "Save workspace to .RData on exit " to "Never"[^saveworkspace]
- **Git / SVN**
  - Activate the option "Enable version control interface for RStudio projects"
  - If the Field "Git executable:" shows `(Not Found)`, browse to your git installation (previous step). This path should look something like this:
    - Windows: `C:/Program Files/Git/bin/git.exe` (**not** `C:/Program Files/Git/cmd/git.exe` or `some-path/git-bash.exe`)
    - Linux / macOS: `/usr/bin/git`
- **Terminal**
  - Set option "New terminals open with" to "Git Bash" 
  
Click on "Ok" to apply the change and close the options menu.

[^restore]: We recommend that you start each RStudio session with a blank slate, as recommended by @wickham2017 see [here](https://r4ds.had.co.nz/workflow-projects.html)
[^saveworkspace]: If we don't restore the workspace at startup, there is no need to save it on exit.



### Introduce yourself to Git{#introduce-yourself-git}

Now it is time to introduce yourself to git. For this, we need to use the shell terminal, which is why we are going to spend a few word on the shell first. 

The shell is a program on your computer whose job is to run other programs. It looks very much like the `R`-console (in the bottom left of RStudio) that you are already know: You have a place to input text which is transferred to (and interpreted by) the computer when you press "enter". RStudio has a shell terminal right next to the `R`-console (tab `Terminal`).

Every Windows comes with two different shell installations: "Command prompt" and "PowerShell". After installing Git we now have a third option, "Git Bash". The shell terminal in RStudio uses "Command prompt" per default, in [the last step](#configure-rstudio) we just switched the shell to "Git Bash".

Now use the terminal in RStudio to introduce yourself:

```
git config --global user.name "Maria Nusslinger"
git config --global user.email "nussmar@email.com"
```

Of course, replace the name and address with your credentials. Use the email address that you will use to create your Github account (which we will do next week).



### Prepare the folder structure for this course{#folder-structure}




By this point, you probably have created a folder for this course somewhere on your computer. In our example, we assume this folder is located here: `C:/Users/yourname/semester2/Modul_CMA` (mentally replace this with your actual path). Before we dive into the exercises, take a minute to think about how you are going to structure your files in this folder. This course will take place over 7 weeks, and in each week you will receive or produce various files. We recommend creating a separate folder for each week, and one folder for the semester project, like so:





```
Course Folder (C:\\Users\\yourname\\semester2\\Modul_CMA)
 ¦--week1                                                
 ¦--week2                                                
 ¦--week3                                                
 ¦--week4                                                
 ¦--week5                                                
 ¦--week6                                                
 ¦--week7                                                
 °--semester_project 
```


For the R-exercises that take place in weeks 1 to 5, we recommend that you create a new RStudio Project each week in subdirectory of the appropriate week. For example, this week your folder structure could look like this: 





```
Folder Week 1 (C:\\Users\\yourname\\semester2\\Modul_CMA\\week1)
 ¦--slides.pdf                                                  
 ¦--my_notes.docx                                               
 ¦--seminar_screenshot.jpg                                      
 °--week1-rexercise                                             
     ¦--week1-rexercise.Rproj                                   
     ¦--wildschwein_BE.csv                                      
     °--my_solution.Rmd   
```


Note: 

- the RStudio Project is located in a subfolder of `C:/Users/yourname/semester2/Modul_CMA/week1` and named `week1-rexercise`.
- `week1-rexercise` is the project's *directory name* and the *project name*
- we realize that that the week number is redundant, there is a reason[^redundancy] for this
- this means each week is a fresh start (which has pros and cons)

[^redundancy]: You will see the project names of all your RStudio Projects listed in RStudio. Having the week number in the project name keeps you from getting confused on which project you are working on.


### Create an RStudio *project* for the first week


Create a new *RStudio Project* (File > New Project > New Directory > New Project). 

1. Click on "Browse" and switch to *your equivalent* of the folder `C:/Users/yourname/semester2/Modul_CMA/week1` (the project we are about to initiate will be be created in a subdirectory of this folder). Click on "open" to confirm the selection
2. In the field "Directory name", type `week1-rexercise`. This will be the name of your RStudio project and it's parent directory.
3. Check the option "Create a git repository"
4. Click on "Create Project"


**You are all set! You can start working on the tasks of exercise 1.**    

<!-- Create a new .R (or .Rmd) File and divide it into the sections necessary in a classical Data Science workflow. In .R Files, "Sections" can be created within RStudio by adding Comments (`#`) with at least 4 trailing dashes, equal, or pound signs ( `-`, `=`,`#`). In .Rmd Files, their are created with leading pound signs (`#`). -->

<!-- Sections allow code folding (try clicking on the small triangle next to the line number) and facilitate navigation (try the shortcut: `Shift`+`Alt`+`J`). We recommend following sections: -->

<!-- - Loading environment / libraries -->
<!-- - Data import -->
<!-- - Data cleansing -->
<!-- - Data analysis and visualization -->





















