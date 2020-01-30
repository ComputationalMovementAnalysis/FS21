#############################################################################
## Defining functions #######################################################
#############################################################################

# base-R has a LOT of useful functions that we can use for our purposes. 
# In addition, there are thousands of packages providing millions of
# additional functions that we can choose from. But sometimes, we want to
# create our own custom functions to fit our needs exactly. 

# If you create your own function, it is advisable to do this in the very beginning
# of the project. I would put it right after importing the packages (because your
# function might depend on a package) and right before importing your rawdata 
# (because you might need a custom function to import your data). Create a file
# named "Custom_Function.R" now and place it using source("Custom_Function.R") in 
# the described position of your Masterfile.

# In my project, I was looking for a way to calculate a simple Euclidean
# distance between two points. "dist()" would take care of this, but I don't
# like the way I need to input my data into the dist() function. Hence, I created
# my own function so I can input my data the way I want to.

# Calculating the Euclidean distance is achieved using this formula:
# https://bigsnarf.files.wordpress.com/2012/03/distance.jpg
# To convert this into an R function, we need to 
# 1) define a function name
# 2) define input variables
# 3) specify what our function should do with these variables
# 4) define how the results are returned

# "euclid" is our function name
euclid <- function(x1,y1,x2,y2){ # "x1, y1..." are the input variables
  # the following line tells our function what to do with the variables:
  return(sqrt((x1-x2)^2+(y1-y2)^2)) 
}# and thats it!

# Note: The order in which you define your input variables will be the order  
# R assumes your data is passed to the function if you don't explicitly
# specify the variables. If you have the positions (600,200) and (800,400)
# and you want to calculate the distance in between them, you can input you data
# like this:
euclid(600,200,800,400)

# If you want to change the order, for example like this:
euclid(600, 800, 200, 400)

# You will get a wrong value unless you define your input variables using the
# same variable names you specified while defining the function:
euclid(x1 = 600, x2 = 800, y1 = 200,y2 = 400)

# futher note that x1, x2, y1 and y2 are LOCAL variables to your function. That means
# that only your function knows what x1 stands for, you cannot call the value of x1 
# outside the function:
x1

# You can use the varible x1 in your project (GLOBAL variable) without creating 
# confusion (except maybe, in your own head)
x1 = 600; y1 = 200; x2 = 800; y2 = 400
euclid(x1,y1,x2,y2)
# ok, this is quite confusing, but not for R!:
euclid(x2 = x1, x1 = x2, y2 = y1, y1 = y2) 

# Now include this custom function in your script "Custom_Function.R" and source it in 
# the place specified in the beginning of this script.
