## Peer Feedback



This weeks exercises are not mandatory. However, we recommend you submit your solutions none the less and give each other peer feedback similar to how you received feedback from us in week 2. If you would like to receive peer feedback on your exercise, provide the URL to your repo in the comment section at the bottom of this page. 

To be notified of any such comments, got to the repo [ComputationalMovementAnalysis/utterances](https://github.com/ComputationalMovementAnalysis/utterances), click on *watch* and select *all activity*.

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
2. Install `inlineComments` from Github ([ratnanil/inlineComments](https://github.com/ratnanil/inlineComments), via `devtools::install_github("ratnanil/inlineComments")`)
4. Restart RStudio
5. Click on *tools > Modify keyboard shortcuts* and add a shortcut for the command *Insert inline comment* (e.g. `Ctrl + Shift + k`) 

Now for each comment, you can highlight the lines you wish to comment and use the keyboard shortcut you assigned in the last step (e.g. `Ctrl + Shift + k`). This should open a window where you can add your comment and if you hit *Create issue*, your comments will be added to your fellow student's repo and a message will show you a link to the new issue.

