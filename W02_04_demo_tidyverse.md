## Demo Tidyverse

Depending on your knowledge of `R`, getting an overview of the data we imported last week might have been quite a challenge. Surprisingly enough, importing, cleaning and exploring your data can be the most challenging, time consuming part of a project. RStudio and the tidyverse offer many helpful tools to make this part easier (and more fun). You have read chapters on `dplyr` and `magrittr` as a preparation for this exercise. Before we start with the exercise however, this demo illustrates a simple approach offered by tidyverse which is applicable to sf-objects.

Assume we want to calculate the timelag between subsequent positions. To achieve this we can use the function `difftime()` combined with `lead()` from `dplyr`. Let's look at these functions one by one.


### `difftime`

`difftime` takes two `POSIXct` values.



```r
now <- Sys.time()

later <- now + 10000

time_difference <- difftime(later,now)
```



```r
time_difference
```

```
## Time difference of 2.777778 hours
```

You can also specify the unit of the output.


```r
time_difference <- difftime(later,now,units = "mins")
```


```r
time_difference
```

```
## Time difference of 166.6667 mins
```


`difftime` returns an object of the Class `difftime`. However in our case, numeric values would be more handy than the Class `difftime`. So we'll wrap the command in `as.numeric()`:

```r
str(time_difference)
```

```
##  'difftime' num 166.666666666667
##  - attr(*, "units")= chr "mins"
```




```r
time_difference <- as.numeric(difftime(later,now,units = "mins"))

str(time_difference)
```

```
##  num 167
```

### `lead()` / `lag()`


`lead()` and `lag()` return a vector of the same length as the input, just offset by a specific number of values (default is 1). Consider the following sequence:


```r
numbers <- 1:10

numbers
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10
```

We can now run `lead()` and `lag()` on this sequence to illustrate the output. `n =` specifies the offset, `default =` specifies the default value used to "fill" the emerging "empty spaces" of the vector. This helps us performing operations on subsequent values in a vector (or rows in a table).


```r
library(dplyr)
```

```
## Warning: package 'dplyr' was built under R version 4.0.4
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
lead(numbers)
```

```
##  [1]  2  3  4  5  6  7  8  9 10 NA
```

```r
lead(numbers,n = 2)
```

```
##  [1]  3  4  5  6  7  8  9 10 NA NA
```

```r
lag(numbers)
```

```
##  [1] NA  1  2  3  4  5  6  7  8  9
```

```r
lag(numbers,n = 5)
```

```
##  [1] NA NA NA NA NA  1  2  3  4  5
```

```r
lag(numbers,n = 5, default = 0)
```

```
##  [1] 0 0 0 0 0 1 2 3 4 5
```




### `mutate()`

Using the above functions (`difftime()` and `lead()`), we can calculate the time lag, that is, the time difference between consecutive positions. We will try this on a dummy version of our wildboar dataset.


```r
wildschwein <- tibble(
  TierID = c(rep("Hans",5),rep("Klara",5)),
  DatetimeUTC = rep(as.POSIXct("2015-01-01 00:00:00",tz = "UTC")+0:4*15*60, 2)
  )

wildschwein
```

```
## # A tibble: 10 x 2
##    TierID DatetimeUTC        
##    <chr>  <dttm>             
##  1 Hans   2015-01-01 00:00:00
##  2 Hans   2015-01-01 00:15:00
##  3 Hans   2015-01-01 00:30:00
##  4 Hans   2015-01-01 00:45:00
##  5 Hans   2015-01-01 01:00:00
##  6 Klara  2015-01-01 00:00:00
##  7 Klara  2015-01-01 00:15:00
##  8 Klara  2015-01-01 00:30:00
##  9 Klara  2015-01-01 00:45:00
## 10 Klara  2015-01-01 01:00:00
```


To calculate the `timelag` with base-R, we need to mention `wildschwein` three times 


```r
wildschwein$timelag  <- as.numeric(difftime(lead(wildschwein$DatetimeUTC), wildschwein$DatetimeUTC))
```

Using `mutate()` we can simplify this operation slightly:


```r
wildschwein <- mutate(wildschwein,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC)))

wildschwein
```

```
## # A tibble: 10 x 3
##    TierID DatetimeUTC         timelag
##    <chr>  <dttm>                <dbl>
##  1 Hans   2015-01-01 00:00:00      15
##  2 Hans   2015-01-01 00:15:00      15
##  3 Hans   2015-01-01 00:30:00      15
##  4 Hans   2015-01-01 00:45:00      15
##  5 Hans   2015-01-01 01:00:00     -60
##  6 Klara  2015-01-01 00:00:00      15
##  7 Klara  2015-01-01 00:15:00      15
##  8 Klara  2015-01-01 00:30:00      15
##  9 Klara  2015-01-01 00:45:00      15
## 10 Klara  2015-01-01 01:00:00      NA
```


### `group_by()`

You might have noticed that `timelag` is calculated across different individuals (`Hans` and `Klara`), which does not make much sense. 
To avoid this, we need to specify that `timelag` should just be calculated between consecutive rows *of the same individual*. We can implement this by using `group_by()`. 


```r
wildschwein <- group_by(wildschwein,TierID)
```

After adding this grouping variable, calculating the `timelag` automatically accounts for the individual trajectories.


```r
wildschwein <- mutate(wildschwein,timelag = as.numeric(difftime(lead(DatetimeUTC),DatetimeUTC)))



wildschwein
```

```
## # A tibble: 10 x 3
## # Groups:   TierID [2]
##    TierID DatetimeUTC         timelag
##    <chr>  <dttm>                <dbl>
##  1 Hans   2015-01-01 00:00:00      15
##  2 Hans   2015-01-01 00:15:00      15
##  3 Hans   2015-01-01 00:30:00      15
##  4 Hans   2015-01-01 00:45:00      15
##  5 Hans   2015-01-01 01:00:00      NA
##  6 Klara  2015-01-01 00:00:00      15
##  7 Klara  2015-01-01 00:15:00      15
##  8 Klara  2015-01-01 00:30:00      15
##  9 Klara  2015-01-01 00:45:00      15
## 10 Klara  2015-01-01 01:00:00      NA
```



### `summarise()`

If we want to summarise our data and get metrics *per animal*, we can use the `dplyr` function `summarise()`. In contrast to `mutate()`, which just adds a new column to the dataset, `summarise()` "collapses" the data to one row per individual (specified by `group_by`).


```r
summarise(wildschwein, mean = mean(timelag, na.rm = T))
```

```
## # A tibble: 2 x 2
##   TierID  mean
## * <chr>  <dbl>
## 1 Hans      15
## 2 Klara     15
```

Note: You can do `mutate()` and `summarise()` on `sf` objects as well. However, `summarise()` tries to coerce all geometries into one object, which can take along time. To avoid this, use `st_drop_geometry()` before using `summarise()`. 

### Piping 

The code above may be a bit hard to read, since it has so many nested functions which need to be read from the inside out. In order to make code readable in a more human-friendly way, we can use the piping command `%>%` from `magrittr`, which is included in `dplyr` and the `tidyverse`. The above code then looks like this:


```r
wildschwein %>%                           # Take wildschwein...
  group_by(TierID) %>%                    # ...group it by TierID
  summarise(                              # Summarise the data...
    mean_timelag = mean(timelag,na.rm = T)# ...by calculating the mean timelag
  )
```

```
## # A tibble: 2 x 2
##   TierID mean_timelag
## * <chr>         <dbl>
## 1 Hans             15
## 2 Klara            15
```


### Bring it all together...

Here is the same approach with a different dataset:


```r
pigs <- tibble(
  TierID = c(8001,8003,8004,8005,8800,8820,3000,3001,3002,3003,8330,7222),
  sex = c("M","M","M","F","M","M","F","F","M","F","M","F"),
  age= c ("A","A","J","A","J","J","J","A","J","J","A","A"),
  weight = c(50.755,43.409,12.000,16.787,20.987,25.765,22.0122,21.343,12.532,54.32,11.027,88.08)
)

pigs
```

```
## # A tibble: 12 x 4
##    TierID sex   age   weight
##     <dbl> <chr> <chr>  <dbl>
##  1   8001 M     A       50.8
##  2   8003 M     A       43.4
##  3   8004 M     J       12  
##  4   8005 F     A       16.8
##  5   8800 M     J       21.0
##  6   8820 M     J       25.8
##  7   3000 F     J       22.0
##  8   3001 F     A       21.3
##  9   3002 M     J       12.5
## 10   3003 F     J       54.3
## 11   8330 M     A       11.0
## 12   7222 F     A       88.1
```

```r
pigs %>%
    summarise(         
    mean_weight = mean(weight)
  )
```

```
## # A tibble: 1 x 1
##   mean_weight
##         <dbl>
## 1        31.6
```

```r
pigs %>%
  group_by(sex) %>%
  summarise(         
    mean_weight = mean(weight)
  )
```

```
## # A tibble: 2 x 2
##   sex   mean_weight
## * <chr>       <dbl>
## 1 F            40.5
## 2 M            25.2
```

```r
pigs %>%
  group_by(sex,age) %>%
  summarise(         
    mean_weight = mean(weight)
  )
```

```
## `summarise()` has grouped output by 'sex'. You can override using the `.groups` argument.
```

```
## # A tibble: 4 x 3
## # Groups:   sex [2]
##   sex   age   mean_weight
##   <chr> <chr>       <dbl>
## 1 F     A            42.1
## 2 F     J            38.2
## 3 M     A            35.1
## 4 M     J            17.8
```


