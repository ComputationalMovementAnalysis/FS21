## Input: Creating Functions ###################################################

testfun <- function(){}

testfun()

class(testfun)


testfun <- function(){print("this function does nothing")}

testfun()

testfun <- function(sometext){print(sometext)}

testfun(sometext = "this function does slightly more, but still not much")

# specify two parameters:
# x: the value  with want to take the root from
# n: the root we want to take (2 for 2nd root)

nthroot <- function(x,n){x^(1/n)}

# Test function by taking the second root of 4. 
# Expecting the result to be 2:
nthroot(x = 4,n = 2)


nthroot(27,3)
nthroot(3,3)

nthroot <- function(x,n = 2){x^(1/n)}

# if not stated otherwise, our function takes the square root
nthroot(10)
# We can still overwrite n
nthroot(10,3)






#- chunkend

head(wildschwein_filter)







## Task 6 ######################################################################
