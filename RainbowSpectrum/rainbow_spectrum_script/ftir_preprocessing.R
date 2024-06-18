#setup work directory
setwd("G:/My Drive/PhD/Doktorat/FTIR analysis/Spektri master/.csv sirovo")

# import library
library(tidyverse)

# define function
process_file = function (file_name, new_file_name) {
  # open .csv file
  df = read.csv(file_name)
  # keep just rows 416-2941
  df = df[416:2905, ]
  # change column names
  colnames(df) = c("wavelength", "intensity")
  # save processed file
  write_csv(df, new_file_name)
}

# set up loop
for (i in 1:30) {
  original_file_name = paste0("Lazar ", i, ".csv")
  new_file_name = paste0("Lazar", i, "processed.csv")
  process_file(original_file_name, new_file_name)
}

# This part of the script should copy apsorbance values from all files and put
# them into one


