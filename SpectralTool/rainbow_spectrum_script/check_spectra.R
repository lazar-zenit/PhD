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

# Check allignment of all spectra
setwd('G:/My Drive/PhD/Doktorat/FTIR analysis/Spektri master')
df2 = read.csv('master_data_table_transposed.csv')
View(df2)

library(ggplot2)
library(tidyr)


df2_long = pivot_longer(df2, cols = starts_with("i"), 
                        names_to = "variable", 
                        values_to = "value"
                        )
View(df2_long)


ggplot(df2_long, aes(x = wavelenght, y = value, color = variable)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Multiple Intensity Variables Against Wavelength",
       x = "Wavelength",
       y = "Intensity",
       color = "Variable") +
  theme(plot.title = element_text(hjust = 0.5))

