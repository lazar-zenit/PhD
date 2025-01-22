# load libraries
library(dplyr)

# Set directory and open file -------------------------------------------------

# Choose working directory and set it
working.dir <- choose.dir()
setwd(working.dir)

# Output folder 
output_folder <- choose.dir()

# Import file
df.master <- read.csv(file.choose(), check.names = FALSE)

# Inspect master file
View(df.master)

# Values and summaries --------------------------------------------------------

# Dataframe summary
print(paste("Number of columns: ", 
            ncol(df.master)))
print(paste("Number of rows: ", 
      nrow(df.master)))
cat(paste(seq_along(colnames(df.master)[1:25]), colnames(df.master)[1:25], sep = ". "), sep = "\n")

# Drop first column (unnamed)
df.master <- df.master[-1]

# check columns
cat(paste(seq_along(colnames(df.master)[1:25]), colnames(df.master)[1:25], sep = ". "), sep = "\n")

# check values in specific column
unique(df.master$Mode)
unique(df.master$Time)

# Filter data and save as new file --------------------------------------------    

# filter file to get data needed
df.filter <- df.master %>%
  filter(Time == 73)

file_name <- "Bv4_73h.csv"
output_path <- file.path(output_folder, file_name)
write.csv(df.filter, file = output_path, row.names = FALSE)



colnames(df.master)
colnames(df.master)[is.na(colnames(df.master)) | colnames(df.master) == ""] <- "Unnamed"
View(df.master)
