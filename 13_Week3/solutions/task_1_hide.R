library(readr)
library(dplyr)
library(ggplot2)


caro60 <- read_delim("00_Rawdata/caro60.csv",",")

caro60 <- caro60 %>%
  mutate(
    stepMean = rowMeans(                       
      cbind(                                   
        sqrt((lag(E,3)-E)^2+(lag(E,3)-E)^2),   
        sqrt((lag(E,2)-E)^2+(lag(E,2)-E)^2),   
        sqrt((lag(E,1)-E)^2+(lag(E,1)-E)^2),   
        sqrt((E-lead(E,1))^2+(E-lead(E,1))^2),  
        sqrt((E-lead(E,2))^2+(E-lead(E,2))^2),
        sqrt((E-lead(E,3))^2+(E-lead(E,3))^2)  
        )                                        
    )
  )

# Note: 
# We present here a slightly different approach as presented in the input:
# - cbind() creates a matrix with the same number of rows as the original dataframe
# - It has 6 columns, one for each Euclidean distance calculation
# - rowMeans() returns a single vector with the same number of rows as the original dataframe
