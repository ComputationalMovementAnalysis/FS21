## Preparation {#w3-preparation}

We need to create a new RStudio Project with Git and Github this week. Last week you created an RStudio Project which was automatically connected to Github. You did this by *first* creating a Github Repo, and then initiating the RStudio Project via *File > New Project > Version Control > Git*  (adding the URL of your Github Repo). This is definitely the easiest way to set up a connection, but what if you have an existing project that you want to connect to Github? 

In this next section, we will go through setting up Git and Github without the use of RStudio. It will take slightly longer than the setup we used last week. Also, you will be confronted with some additional jargon. 


\BeginKnitrBlock{rmdimportant}<div class="rmdimportant">You now have two choices:

1. Set up a new RStudio (with Git and Github) for this weeks exercises as described last week in [Step 3](#create-github-repo) and [Step 4](#w2-project) *or*
2. Follow the instructions below to set up your RStudio Project with Git and Github with a slightly more complicated, but also more canonical way

Either way: Report the URL of your new repo back to us via Moodle!</div>\EndKnitrBlock{rmdimportant}

As additional ressources to learning Git, we highly recommend:

- [The video tutorials by Corey Schafer](https://www.youtube.com/watch?v=HVsySz-h9r4&list=PL-osiE80TeTuRUfjRe54Eea17-YfnOOAx&ab_channel=CoreySchafer). For example, *[Git Tutorial for Beginners: Command-Line Fundamentals](https://youtu.be/HVsySz-h9r4)* gives a nice introduction to the command line
- [Happy Git with Github for the useR](https://happygitwithr.com/) is an excellent, easy to read, openly available book, written specifically for students working with R and RStudio in data science and related fields


### Step 1: Create a "normal" RStudio Project

Create a new RStudio Project *File > New Project > New Directory > New Project*.
This will create a "normal" RStudio Project *without* Git version control (and consequently without a Github connection). This is a typical situation for a project that you started without version control in mind. Choose the following settings:

- **Directory name**: Choose a directory name that suits your structure
- **Create project as a subdirectory of**: Choose a parent directory that suits your folder structure
- **Create a git repository**: not checked (we will do this manually in the next step)
- **Use renv with this project**: not checked

### Step 2: Activate Git Version Control


Activating Git Version Control for your project is one line of code. In your shell terminal, type the following command (which is what RStudio effectively does automatically when you activate the *Create a git repository* option while creating your project):

```
git init
```

You should get a message, saying `Initialized empty Git repository in C:/path/to/your/directory/.git/`. You will see this folder (named `.git`) in your project's root directory (check your "Files" pane ). If you don't see it there, click *Refresh file listing* (refresh symbol to the very right of the files pane). If you still dont see it, make hidden files visible (*Files pane > More > Show hidden files*)

To see the "Git" Pane in RStudio, reload RStudio either by restarting it or clicking on the name of your RStudio project in the top right corner of RStudio and selecting your project from the project list). 


### Step 3: Rename branch

In your Git pane, you will see that you do not have a branch yet, it says `(no branch)` in the top right corner. But what is  branch?

Branches are a way to have multiple versions of your project, which is especially useful if you want to do experiments that you are unsure about. We will not cover branches in this course, but it's important that you have heard of the term, since its considered to be Git's "Killer feature".

Once you make your first commit, Git will automatically create a branch named `master`. Test this by committing the`.gitignore` and `...*.Rproj`-File. 
`master` is just a convention for the main (and maybe only) version of your project. Since 2020, there are efforts to avoid offensive jargon in tech, including `master`. In this effort, Github has switched to using `main` as the name for the main branch, while Git still uses `master`. We can rename our `master` branch to `main` with the following line of code (note that you must have committed something first):

```
git branch -M main
```


### Step 4: Create a Github Repository 

Now create a Github Repository following the instructions from [last week](#create-github-repo). This time however, don't check `Add a README file`.
Copy the https URL to your Github repo, which should look something like this: `https://github.com/YOUR-GITHUB-USERNAME/cma-week3.git`


### Step 5: Connect to Github

To connect your (local) RStudio Project to Github, we have to set up our Github repo to be our so called "*remote*" repository. We could have multiple *remotes*, which is why we need to name it, and the convention is to call it `origin`. To createa a *remote* named `origin`, type the following command in your shell terminal:

```
git remote add origin https://github.com/YOUR-GITHUB-USERNAME/cma-week3.git
```

The first time we push to this *remote* repository, we need to specify the an upstream, so that future `git push` will be directed to the correct remote branch. We can to this with the `--set-upstream`[^setupstream]

[^setupstream]: Synonymously you can use `-u` instead of `--set-upstream`.

```
git push --set-upstream origin main
```

This command prints a couple of messages, ending with the following statement: `Branch 'main' set up to track remote branch 'main' from 'origin'.`. Now that the upstream (i.e.) tracking branch is correctly set up, you can also push via the Git pane in RStudio (you might need to refresh the Git pane first).


<!-- ### Closing remarks -->

<!-- This setup is a bit more complex that how we set up RStudio with Github last week, but it also makes you independent of RStudio and gives you a look behind the scenes. And by the way, you will see the correct command line instructions on the landing page of your Github Repo after you created it, so next time you can copy and paste the commands from there.  -->





