# load libraries
library(ggplot2)
library(FactoMineR)
library(factoextra)
library(tidyr)
library(gridExtra)

# load prepared dataset in .csv format
# omnic_processed_all_pretty_MV_table.csv for test
df <- read.csv(file.choose())

# inspect dataframe and decide which columns go into PCA
View(df)