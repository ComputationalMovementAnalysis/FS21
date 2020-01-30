#########################################################################
## Our own custom made functions ########################################
#########################################################################

#########################################################################
## from Lesson 2 ########################################################
#########################################################################

# Calculates the Euclidean Distance in a 2D Landscape
euclid <- function(x1,y1,x2,y2){
  return(sqrt((x1-x2)^2+(y1-y2)^2)) 
}

#########################################################################
## from Lesson 3 ########################################################
#########################################################################

# Groups sequences of "TRUE" Values
number_groups <- function(input,include_next = F){
  # Replace NAs with FALSE for cumsum() to work
  input[is.na(input)] <- FALSE 
  # Make Groups using cumsum()
  group = head(cumsum(c(TRUE,!input)),-1)
  # Should the first "FALSE" Value be included in the preceding group?
  if(include_next == F){
    # default: No, so just discard all groups where "input" is "FALSE"
    group[!input] <- NA
  } else{
    # Compare each value with the next
    compare <- head(group,-1) == tail(group,-1)
    # determine unique values
    uniques <- !(c(compare,F) | c(F,compare))
    # remove unique values
    group[which(uniques)] <- NA
  } 
  # convert into factors
  group <- as.factor(group)
  # rename the factors
  levels(group) <- 1:length(levels(group))
  return(group)
}


# Rounds values to the nearest multiple
round_multiple <- function(value,multiple){
  round(value/multiple,0)*multiple
}

# Finds local minima. Cannot handle special cases (e.g. when there is no
# single minimal value).
local_min <- function(values){
  diffs <- head(values,-1) - tail(values,-1)
  return(c(diffs < 0,T) & c(T,diffs > 0))
}
