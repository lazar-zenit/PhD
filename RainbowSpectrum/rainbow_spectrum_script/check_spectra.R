#setup work directory
setwd('G:/My Drive/PhD/Doktorat/FTIR analysis/Spektri master/Dekonvolucija')

# load the libraries
library(ggplot2)
library(tidyr)

# open the .csv file
df = read.csv('fityk_input.csv')

# check the dataframe
View(df)

df_long = df %>% pivot_longer(cols = -wavenumber, 
                              names_to = "variable", 
                              values_to = "value"
                              )

plot = ggplot(df_long, aes(x = wavenumber, y = value, color = variable)) +
  geom_line() +
  facet_wrap(~ variable, ncol = 5, nrow = 6, scales = "free_y") +
  theme_bw()

# Display the plot
print(plot)
