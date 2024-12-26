# load libraries
library(dplyr)

# import master file
df.master <- read.csv(file.choose(), check.names = FALSE)

# inspect master file
View(df.master)

print(paste("Number of columns: ", 
            ncol(df.master)))
print(paste("Number of rows: ", 
      nrow(df.master)))
cat(paste(seq_along(colnames(df.master)[1:25]), colnames(df.master)[1:25], sep = ". "), sep = "\n")




df.master.summary
                             
length(unique(df.master$Time))


# filter file to get data needed
df.filter <- df.master %>%
  filter(Time == 70)