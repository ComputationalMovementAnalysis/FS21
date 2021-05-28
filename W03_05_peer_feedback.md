## Peer Feedback



For the submissions of the exercises of week 3, you will give *each other* peer feedback similiar to how you received feedback from us in week 2. Each of you will be assigned a fellow student to provide feedback and will receive feedback from a different student. You will get the URL of the repo that you provide feedback via moodle.

Using the URL of the Github Repo to which you will provide feedback, create a new RStudio Project following [step 4](#w2-project) we described in week 2. This will create a clone of that project on your local machine and open it in RStudio.

Try to run the code written by your fellow student locally. *TODO*: Add more detail on what the students should provide feedback on.

Git and Github provide rich functionalities to give feedback on code. We recommend you use *issues* to deliver your feedback to your peer (in the way we provided feedback in week 2). Using issues you can reference specific lines of code, similar like the *comment* feature in Microsoft Word. You have two ways to reference of specific line(s):

1. via [the browser (on github.com)](#issues-option1)
2. via [our RStudio Addin](#issues-option2)

Option 1 requires no initial set up and is quite straightforward. However, you will need to switch back and forth between RStudio and Github, which can be quite tiresome. 

Option 2 will require 10 minutes of set up, but should be faster to use afterwards. We therefore recommend this option, however: We developed this addin ourselves and it might not be stable for everyone. Please contact us if it does not work for you.

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

