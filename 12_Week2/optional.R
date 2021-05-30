library(grid) # just for the arrows


# Advanced solution including the building of functions. Only for very motivated students!

euclid <- function(x1,y1,x2,y2){
  return(sqrt((x1-x2)^2+(y1-y2)^2))
}
turning_angle <- function(x,y,lead_lag = 1){
  if(length(x) < 3){stop("Minimum length of x and y is 3")}
  if(length(x) != length(y)){stop("x and y must be of the same length")}
  p1x <- lag(x,lead_lag)
  p1y <- lag(y,lead_lag)
  p2x <- x
  p2y <- y
  p3x <- lead(x,lead_lag)
  p3y <- lead(y,lead_lag)
  p12 <- euclid(p1x,p1y,p2x,p2y)
  p13 <- euclid(p1x,p1y,p3x,p3y)
  p23 <- euclid(p2x,p2y,p3x,p3y)
  rad <- acos((p12^2+p23^2-p13^2)/(2*p12*p23))
  grad <- (rad*180)/pi
  grad[p12 == 0 | p23 == 0] <- NA
  d <-  (p3x-p1x)*(p2y-p1y)-(p3y-p1y)*(p2x-p1x)
  d <- ifelse(d == 0,1,d)
  d[d>0] <- 1
  d[d<0] <- -1
  d[d==0] <- 1
  turning <- grad*d*-1+180
  return(turning)
}

# Running the functions on some dummy data:
set.seed(20)
data.frame(x = cumsum(rnorm(10)),y = cumsum(rnorm(10))) %>%
  mutate(angle = as.integer(turning_angle(x,y))) %>%
  ggplot(aes(x,y)) +
  geom_segment(aes(x = lag(x), y = lag(y), xend = x,yend = y),arrow = arrow(length = unit(0.5,"cm"))) +
  geom_label(aes(label = paste0(angle,"<U+00C2><U+00B0>")),alpha = 0.4,nudge_x = 0.2, nudge_y = 0.2) +
  coord_equal()
