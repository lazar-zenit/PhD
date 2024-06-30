# set work directory
setwd("G:/My Drive/PhD/Doktorat/FTIR analysis/Spektri master/Korelacija spektara")

# read and inspect dataframe
df = read.csv('za korelaciju centralne tačke.csv')
View(df)

# CHECK THE NORMALITY
# vizualize distribution to check normality
#reshape the dataframe and check it
library(tidyr)
df_long = pivot_longer(df, cols = starts_with("c"), 
                       names_to = "variable", 
                       values_to = "value")
# plot the histograms
ggplot(df_long, aes(x = value, fill = variable)) + 
  geom_histogram(bins = 30, 
                 alpha = 0.6, 
                 position = 'identity') +
  facet_wrap(~ variable, 
             scales = 'free') +
  theme_minimal() +
  labs(title = "Histograms of Intensity Variables",
       x = "Value",
       y = "Frequency",
       fill = "Variable") +
  theme(plot.title = element_text(hjust = 0.5))

# VISUAL INSPECTION
# plot the all spectral lines
ggplot(df_long, aes(x = wavenumber, y = value, color = variable)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Multiple Intensity Variables Against Wavelength",
       x = "Wavelength",
       y = "Intensity",
       color = "Variable") +
  theme(plot.title = element_text(hjust = 0.5))


# CORRELATION
# make correlation matrix
cor_matrix = cor(df)
print(cor_matrix)

# t-test for the matrix
library(Hmisc)
rcorr(as.matrix(df))

# make data suitable for graphs
library(reshape2)
melted_cor = melt(cor_matrix)

# plot the correlation matrix
library(ggplot2)
ggplot(data = melted_cor, aes(x = Var1, y= Var2, fill = value)) +
  geom_tile() + 
  scale_fill_gradient2(low = "blue", 
                       high = "red", 
                       mid = "white",
                       midpoint = 0.975, 
                       limit = c(0.95,1), 
                       space="Lab",
                       name="Pearson correlation\n of FTIR spectra") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, 
                                   vjust = 1, 
                                   size = 12, 
                                   hjust = 1)) +
  coord_fixed()

# alternative for simpler plotting
library(corrplot)
corrplot(cor_matrix)

# CHECK THE GRAPH VISUALY
#reshape the dataframe and check it


