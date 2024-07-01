# set working directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/stefan")

# read and inspect dataframe - weat
wheat = read.csv('psenica.csv')
View(wheat)

# remove zero columns
library(dplyr)
wheat_new <- subset(wheat, rowSums(data != 0) > 0)
View(wheat_new)
