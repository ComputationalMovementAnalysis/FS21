#############################################################################
## Funktionen einlesen ######################################################
#############################################################################

######################################
## Raumbezogene Funktionen ###########
######################################

unique.na.rm <- function(input){
  output <- unique(input)
  output <- output[!is.na(output)]
  return(output)
}



euclid <- function(x1,y1,x2,y2){
  return(sqrt((x1-x2)^2+(y1-y2)^2))
}

# um ein Dataframe aus den kleinsten Abstand zwischen Reh und Mensch zu bekommen
minLine <- function(input,fourcols){
  minLine <- slice(filter(input,RoeTime == T),which.min(RoeHumanDist))
  minLine <- as.data.frame(minLine)[,fourcols]
  minLine <- as.numeric(minLine)
  minLine <- matrix(minLine, nrow = 2, ncol = 2, byrow = T)
  minLine <- as.data.frame(minLine)
  colnames(minLine) <- c("X","Y")
  return(minLine)
}

minLine <- function(input,fourcols){
  minLine <- slice(filter(input,RoeTime == T),which.min(RoeHumanDist))
  minLine <- as.data.frame(minLine)[,fourcols]
  minLine <- as.numeric(minLine)
  minLine <- matrix(minLine, nrow = 2, ncol = 2, byrow = T)
  minLine <- as.data.frame(minLine)
  colnames(minLine) <- c("X","Y")
  return(minLine)
}

# Return a colortable from a Rasterfile in a way that
# can be returned to ggplot2 (requres "Raster")
getColTab <- function(rasterfile, greyscale = F){
  colTab <- raster::colortable(rasterfile)
  if(greyscale == T){
    colTab <- col2rgb(colTab)
    colTab <- colTab[1,]*0.2126 + colTab[2,]*0.7152 + colTab[3,]*0.0722
    colTab <- rgb(colTab,colTab,colTab, maxColorValue = 255)
  }
  names(colTab) <- 0:(length(colTab)-1)
  return(colTab)
}

# Crop a rasterfile to the extent delivered by a 
# dataframe and X/Y Coordinates (requres "Raster")
cropToExtent <- function(xyData,X,Y,rasterfile){
  xyData <- as.data.frame(xyData)
  min.X <- min(xyData[,X],na.rm = T)
  max.X <- max(xyData[,X],na.rm = T)
  min.Y <- min(xyData[,Y],na.rm = T)
  max.Y <- max(xyData[,Y],na.rm = T)
  ext <- raster::extent(min.X,max.X,min.Y,max.Y)
  map_crop <- raster::crop(rasterfile,ext)
  return(map_crop)
}


interpolate <- function(values,time){
  zoo.obj <- zoo(cbind(values[!is.na(values)]),time[!is.na(values)])
  zoo.interpol <- na.approx(zoo.obj, xout = time)
  gps.interpol <- as.data.frame(zoo.interpol)
  return(gps.interpol[,1])
}


# http://stackoverflow.com/questions/14064097/r-convert-between-zoo-object-and-data-frame-results-inconsistent-for-different
zoo.to.data.frame <- function(x, index.name="Date") {
  stopifnot(is.zoo(x))
  xn <- if(is.null(dim(x))) deparse(substitute(x)) else colnames(x)
  setNames(data.frame(index(x), x, row.names=NULL), c(index.name,xn))
}



######################################
## Zeitbezogene Funktionen ###########
######################################


# Convert the Timezone of a POSIXct Object into a new Timezone
# the hour:min value DO change
tzConvert <- function(datetime,tzone){
  attr(datetime, "tzone") <- tzone
  return(datetime)
}

# Convert the Posix Object into a character string in the format that
# PostgreSQL likes
posix_postgre <- function(datetime){
  require(lubridate)
  tzone <- tz(datetime)
  return(
    paste0(
      strftime(datetime, tz = tzone, usetz = F),
      substr(strftime(datetime, tz = tzone, usetz = F, format = "%z"),1,3)
    )
  )
}


roundHourTo <- function(DateTime,multiple){
  x <- as.POSIXlt(DateTime)
  hour_dec <- x[["hour"]]+x[["min"]]/60+x[["sec"]]/(60*60)
  hour_round <- round(hour_dec/multiple)*multiple
  x[["hour"]] <- hour_round
  x[["min"]] <- 0
  x[["sec"]] <- 0
  return(as.POSIXct(x))
}



roundSecTo <- function(DateTime,multiple){
  x <- as.POSIXlt(DateTime)
  sec <- x[["sec"]]
  sec_round <- round(sec/multiple)*multiple
  x[["sec"]] <- sec_round
  return(as.POSIXct(x))
}

# ben?tigt package "lubridate"
add_days <- function(firstday,amount){
  timezone <- tz(firstday)
  vec <- as.POSIXct(rep(NA, amount))
  for(x in 1:amount){vec[x] <- firstday+days(x-1)}
  attr(vec, "tzone") <- timezone
  return(vec)
}

subtract_days <- function(lastday,amount){
  timezone <- tz(lastday)
  vec <- as.POSIXct(rep(NA, amount))
  for(x in 1:amount){vec[amount-x+1] <- lastday-days(x-1)}
  attr(vec, "tzone") <- timezone
  return(vec)
}



difftime.abs.min <- function(one,two){
  as.integer(abs(difftime(one,two,units = "mins")))
}

difftime.abs.sec <- function(one,two){
  as.integer(abs(difftime(one,two,units = "secs")))
}



getTwoSeasons <- function(input.date){
  numeric.date <- 100*month(input.date)+day(input.date)
  ## input Seasons upper limits in the form MMDD in the "break =" option:
  cuts <- base::cut(numeric.date, breaks = c(0,415,1015,1231)) 
  # rename the resulting groups (could've been done within cut(...levels=) if "Winter" wasn't double
  levels(cuts) <- c("Winter", "Summer","Winter")
  return(cuts)
}

getFourSeasons <- function(input.date){
  numeric.date <- 100*month(input.date)+day(input.date)
  ## input Seasons upper limits in the form MMDD in the "break =" option:
  cuts <- base::cut(numeric.date, breaks = c(0,229,531,831,1130,1231)) 
  # rename the resulting groups (could've been done within cut(...levels=) if "Winter" wasn't double
  levels(cuts) <- c("Winter","Spring","Summer","Autumn","Winter")
  return(cuts)
}

# custom function to cut() hour and deal with the problematic of the that 23h and 00h are close values
# cannot deal with numerus special cases, including when the breaks include 0
# Breaks need to defined starting with the first hour after 00h
cut.hour <- function(input, breaks){
  newbreaks = c(0,breaks,24)
  firstcut <- cut(input, newbreaks,include.lowest = T)
  newlevels <- levels(firstcut)[2:(length(levels(firstcut))-1)]
  addlevel <- paste0("(",tail(breaks, 1),",",head(breaks,1),"]")
  newlevels <- c(addlevel,newlevels,addlevel)
  levels(firstcut) <- newlevels
  return(firstcut)
}

hour.integer <- function(datetime){
  hour(datetime) + minute(datetime)/60
}

######################################
## Funktionen f?r Plots ##############
######################################

# function for number of observations in ggplot2
# http://stackoverflow.com/a/15661466/4139249
give.n <- function(x){
  return(c(y = median(x)*1.05, label = length(x))) # y = median(x)*1.05
  # experiment with the multiplier to find the perfect position
}

# function for mean labels in ggplot2
mean.n <- function(x){
  return(c(y = median(x)*0.97, label = round(mean(x),2))) 
  # experiment with the multiplier to find the perfect position
}


# To add beautiful log lables and breaks
# http://stackoverflow.com/a/22227846/4139249
base_breaks <- function(n = 10){
  function(x) {
    axisTicks(log10(range(x, na.rm = TRUE)), log = TRUE, n = n)
  }
}



# ben?tigt package "lubridte"
overlap.seconds <- function(start1,end1,start2,end2){
  as.integer(
    as.duration(
      intersect(
        new_interval(start1,end1),
        new_interval(start2,end2)
      )
    )
  )
}


gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

######################################
## Sonstige funktionen ###############
######################################

# Passwort eingeben
# http://stackoverflow.com/a/3104339/4139249
getPass<-function(){  
  # require(tcltk);  
  wnd<-tktoplevel();tclVar("")->passVar;  
  #Label  
  tkgrid(tklabel(wnd,text="Enter password:"));  
  #Password box  
  tkgrid(tkentry(wnd,textvariable=passVar,show="*")->passBox);  
  #Hitting return will also submit password  
  tkbind(passBox,"<Return>",function() tkdestroy(wnd));  
  #OK button  
  tkgrid(tkbutton(wnd,text="OK",command=function() tkdestroy(wnd)));  
  #Wait for user to click OK  
  tkwait.window(wnd);  
  password<-tclvalue(passVar);  
  return(password);  
} 

# Create a custom logical vector with a specified length and a sampling unit
# in order to select every n-th Bike Fix.
custom_logVec <- function(vec.length, sampling.unit){
  vec <- vector(length = vec.length)
  input <- seq(1,vec.length,sampling.unit)
  vec[input] <- T
  return(vec)
}


inv.dist.w <- function(i.interval,i.value,exp = 1){
  if(all(i.value == 0)){
    value <- 0
  } else if(any(i.interval == 0)){
    value <- i.value[which(i.interval == 0)]
  } else {
    i.weight <- i.value/(i.interval^exp)
    value <- sum(i.value*i.weight)/sum(i.weight)
  }
  return(value)
}


round.to <- function(number,multiple,upDown = 0){
  if(upDown == 0){round(number/multiple,0)*multiple}
  else if(upDown > 0){ceiling(number/multiple)*multiple}
  else {floor(number/multiple)*multiple}
}


# die Auswahl mittels logical Vector um eine definierte anzahl Elemente erweitern
# https://stat.ethz.ch/pipermail/r-help/2004-March/047663.html

expand.true<-function(x,span=1,direction = 0){
  # direction (of expansion):
  #  0 means both ways
  # >0 means forwards only
  # <0 means backwards only
  if(direction == 0){
    
    ind<-outer(which(x),(-span):span,"+")
  } else if(direction > 0){
    ind<-outer(which(x),0:span,"+")
  } else{
    ind<-outer(which(x),(-span):0,"+")
  }
  ind<-ind[ind>0 & ind <= length(x)]
  x[ind]<-TRUE
  return(x)
}



# `%notin%` <- function(x,y) !(x %in% y) 
# 
# expand.gr.forward <- function(x.gr){
#   items <- which(!is.na(x.gr))
#   items.plus <- c(1,items+1)
#   sel <- !(items.plus %in% items)
#   sel.idx <- items.plus[sel]
#   x.gr[sel.idx] <- x.gr[sel.idx-1]
#   return(x.gr)
# }


# Aufeinanderfolgende T werte als gruppe aufsteigend nummerieren
# http://stackoverflow.com/questions/12984339/assigning-values-in-a-sequence-to-a-group-of-consecutive-rows-leaving-some-rows

# Groups sequences of "TRUE" Values
number.groups <- function(input,include_next = F, keep_uniques = F){
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
    if(keep_uniques == F){
      group[which(uniques)] <- NA
    } 
  } 
  # convert into factors
  group <- as.factor(group)
  # rename the factors
  levels(group) <- 1:length(levels(group))
  if(include_next == F & keep_uniques == T){
    warning(
      "This combination of options has not been programmed yet. 
      If you really need it, adjust the function. Otherwise, 
      the option 'keep_unique' will be treated as FALSE")
  }
  return(group)
  }



# Finds local minima. Cannot handle special cases (e.g. when there is no
# single minimal value).
local.min <- function(values,include_edges = "both"){
  diffs <- head(values,-1) - tail(values,-1)
  if(include_edges == "both"){
    minima <- c(diffs < 0,T) & c(T,diffs > 0)
  } else if(include_edges == "start"){
    minima <- c(diffs < 0,F) & c(T,diffs > 0)
  } else if(include_edges == "end"){
    minima <- c(diffs < 0,T) & c(F,diffs > 0)
  } else if(include_edges == "none"){
    minima <- c(diffs < 0,F) & c(F,diffs > 0)
  } else{
    stop("This option is not available. Only 'both' (default),'start', 'end' or 'none'")
  }
  return(minima)
}

# Takes a list of dataframes and compares all df's with each other (no repeats)
# and joins them the "DateTime" Column
temporal_join <- function(matrices,joincol){
  ids <- names(matrices)[!is.na(names(matrices))]
  if(is.null(ids)){
    print("Input data (list) must have names")
  } else{
    nr_values <- length(ids)
    combinations <- combn(ids, 2)
    nr_combinations <- ncol(combinations)
    result_list <- list()
    for (pair in 1:nr_combinations){
      print(paste("Processing combination", pair, "of", nr_combinations,"..."))
      id1 <- combinations[1,pair]
      id2 <- combinations[2,pair]
      traj12 <- inner_join(matrices[[id1]], matrices[[id2]], by = joincol)
      if(nrow(traj12) > 0){
        # traj12 <- arrange(traj12, as.name(joincol))
        result_list[[pair]] <- traj12
      }
    }
    result_df <- bind_rows(result_list)
    return(result_df)
  }
}


# returns string w/o leading or trailing whitespace
# http://stackoverflow.com/a/2261149/4139249
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
