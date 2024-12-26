# load libraries
library(dplyr)

# import master file
df.master <- read.csv(file.choose(), check.names = FALSE)

# save file
output_folder <- choose.dir()

# inspect master file
View(df.master)

# dataframe summary
print(paste("Number of columns: ", 
            ncol(df.master)))
print(paste("Number of rows: ", 
      nrow(df.master)))
cat(paste(seq_along(colnames(df.master)[1:25]), colnames(df.master)[1:25], sep = ". "), sep = "\n")

# drop first column (unnamed)
df.master <- df.master[-1]

# check columns
cat(paste(seq_along(colnames(df.master)[1:25]), colnames(df.master)[1:25], sep = ". "), sep = "\n")

# check values in specific column
unique(df.master$Mode)
unique(df.master$Time)

                             
# filter file to get data needed
df.filter <- df.master %>%
  filter(Mode ==  'Abs Transmittance' & Time == 46.5)


file_name <- "Transmittance_Time_46_5h_330_1200.csv"
output_path <- file.path(output_folder, file_name)
write.csv(df.filter, file = output_path, row.names = FALSE)
