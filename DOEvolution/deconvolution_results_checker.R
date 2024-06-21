# setup the working directory
setwd("G:/My Drive/PhD/Doktorat/FTIR analysis/Spektri master/Dekonvolucija")

# load and check the data
data = read.csv("parser_za_obradu.csv")
View(data)

# load the library
library(dplyr)

# filter the data
filtered_df = data %>%
  filter(grepl("center", param))

# check filtered data
View(filtered_df)

# ensure that data is numeric
filtered_df$value = as.numeric(filtered_df$value)
filtered_df$error= as.numeric(filtered_df$error)

# give summary statistic of filtered results
summary(filtered_df)

# or do it for each column individualy and print results
value_summary = summary(filtered_df$value)
error_summary = summary(filtered_df$error)
cat("Value summary stats:\n", value_summary, "\n",
    "Error summary stats:\n", error_summary, "\n",
    sep = ""
    )

# enter yout bands of interest
bands_of_interest = c(1079)

# see distribution of values
library(ggplot2)
ggplot(filtered_df, aes(x = value)) + 
  geom_histogram(bins = 20, fill = "blue", alpha = 0.5, color = "black") +
  #geom_errorbar(aes(ymin = value - error, ymax = value + error, x = value),
                #width = 0.2, color = "red") +
  scale_x_continuous(breaks = seq(900, 1150, by=20)) +
  geom_vline(x_intercept = bands_of_interest, color = "red", size = 1)
  theme_minimal() +
  labs(title = "Distribution of convoluted peak centers",
       x = "value",
       y = "frequency")
  

