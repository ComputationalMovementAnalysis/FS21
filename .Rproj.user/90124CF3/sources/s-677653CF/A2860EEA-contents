summary(caro60$stepMean)

ggplot(caro60, aes(stepMean)) +
  geom_histogram(binwidth = 1) +
  geom_vline(xintercept = mean(caro60$stepMean,na.rm = TRUE))

caro60 <- caro60 %>%
  mutate(
    static = stepMean < mean(caro60$stepMean,na.rm = TRUE)
  ) 
