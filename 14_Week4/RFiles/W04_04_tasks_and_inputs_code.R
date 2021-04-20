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



wildschwein_BE$timelag  <- as.numeric(difftime(lead(wildschwein_BE$DatetimeUTC),
                                               wildschwein_BE$DatetimeUTC,
                                               units = "secs"))


wildschwein_BE <- mutate(wildschwein_BE,timelag = as.numeric(difftime(lead(DatetimeUTC),
                                                                      DatetimeUTC,
                                                                      units = "secs")))

#- chunkend

head(wildschwein_filter)


summarise(st_set_geometry(wildschwein_BE,NULL), mean_timelag = mean(timelag, na.rm = T))


wildschwein_BE %>%                     # Take wildschwein_BE...
  st_set_geometry(NULL) %>%            # ...remove the geometry column...
  group_by(TierID) %>%                 # ...group it by TierID
  summarise(                           # Summarise the data...
    mean_timelag = mean(timelag,na.rm = T) # ...by calculating the mean timelag
  )

pigs = data.frame(
  TierID=c(8001,8003,8004,8005,8800,8820,3000,3001,3002,3003,8330,7222),
  sex=c("M","M","M","F","M","M","F","F","M","F","M","F"),
  age=c("A","A","J","A","J","J","J","A","J","J","A","A"),
  weight=c(50.755,43.409,12.000,16.787,20.987,25.765,22.0122,21.343,12.532,54.32,11.027,88.08)
)

pigs

pigs %>%
    summarise(         
    mean_weight = mean(weight)
  )

pigs %>%
  group_by(sex) %>%
  summarise(         
    mean_weight = mean(weight)
  )

pigs %>%
  group_by(sex,age) %>%
  summarise(         
    mean_weight = mean(weight)
  )


## Task 6 ######################################################################

# Store coordinates in a new variable

coordinates <- st_coordinates(wildschwein_BE)

head(coordinates)
