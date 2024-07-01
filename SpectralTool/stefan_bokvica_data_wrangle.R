# set working directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/stefan")

# read and inspect dataframe - weat
wheat = read.csv('psenica.csv')
View(wheat)

# remove zero columns
library(dplyr)

wheat_new = filter_if(wheat, is.numeric, all_vars((.) != 0))
View(wheat_new)
