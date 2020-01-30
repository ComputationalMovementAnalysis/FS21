#############################################################################
## Introduction to data.table and foverlaps() ###############################
#############################################################################

# We have mountainbike and roe deer gps data. We know that the mountainbikes
# approached the roe deer in order to test their reaction. But when 
# and where did a biker meet a roe deer? There are a multitude of ways 
# find such a movement pattern computationally, but none of them is easy. 

# We will use a solution including the package data.table. Data.tables are an 
# enhanced version of data.frames. But data.table offers much more than just 
# a sophisticated way of storing data, there are some very very advanced functions 
# within data.table, one of which we will use to merge our deer and bike data 
# on temporal basis, and hence detect the "meeting" pattern.

# But first, a quick look at data.table. Data.table has a whole different
# mindset as to how data should be managed. This makes the beginning a little
# hard and might prevent one from switching from data.frame to data.table altoghether. 

# But in the beginning, there is no need for that anyway. It's enough to know
# that data.tables exist and that they are THE method of choice when you are 
# working with big data and/or sequential data like we have with our GPS-trajectory
# data.

# Here is a very nice introduction to data.table (videos & exercises):
# https://www.datacamp.com/courses/data-table-data-manipulation-r-tutorial

# Now for a brief introduction to foverlap(): Like I mentioned, we need to merge
# our deer and bike data using a termporal index (aka key). Since the timestamps
# between roe deer and bikes are slightly apart (mostly anyways) we cannot work
# with just ONE key (point in time), but with two keys (timespan). We have to decide
# within which timespan we would consider two gps locations to be equal.

# foverlap() requires two data.tables with at least two keys each: The minimal
# timewindow and the maximum timewindow. In short, foverlaps checks whether
# the two intervals overlap. 

# Since it's a merge operation, there are many special cases to consider: What
# happens if multiple values overlap? What if none overlap? Do they need to overlap
# fully or is partial overlapping enough? Let's play through a couple of cases with
# some dummy data taken from here: 
# http://www.rdocumentation.org/packages/data.table/functions/foverlaps

require(data.table)

## simple example (note: temporal overlaps is just one possibility)
x = data.table(start=c(5,31,22,16), end=c(8,50,25,18), val2 = 7:10)
y = data.table(start=c(10, 20, 30), end=c(15, 35, 45), val1 = 1:3)

setkey(x, start, end) # scrictly not necessary for x
setkey(y, start, end)

## return overlap left-join. NOTE: counterintuitively, the left side which
## is input in the foverlaps function (x in our case) ends up on the right side
## of our resulting data.table. Plus, duplicate columns recieve a preceeding "i."
## on the left side.
foverlaps(x, y, type="any") 

## returns overlap inner-join
foverlaps(x, y, type="any", nomatch = 0) 

## returns inner-join only if x's interval is WITHIN y's interval
foverlaps(x, y, type="within", nomatch = 0) 

## foverlaps supports any number of keys (ex: in genomics)
x = data.table(chr=c("Chr1", "Chr1", "Chr2", "Chr2", "Chr2"), 
               start=c(5,10, 1, 25, 50), end=c(11,20,4,52,60))

y = data.table(chr=c("Chr1", "Chr1", "Chr2"), start=c(1, 15,1), 
               end=c(4, 18, 55), geneid=letters[1:3])

setkey(x, chr, start, end)
setkey(y, chr, start, end)

foverlaps(x, y, type="any")
foverlaps(x, y, type="any", nomatch=0L)
foverlaps(x, y, type="within", which=TRUE)
foverlaps(x, y, type="within")
foverlaps(x, y, type="start")
