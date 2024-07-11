# set work directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets")

# read and inspect dataframe
df = read.csv('all_spectra_std_order_corr_test.csv')
View(df)

# CHECK THE NORMALITY
# vizualize distribution to check normality
#reshape the dataframe and check it
library(tidyr)
df_long = pivot_longer(df, cols = starts_with("i"), 
                       names_to = "variable", 
                       values_to = "value")
# plot the histograms
library(ggplot2)
ggplot(df_long, aes(x = value, fill = variable)) + 
  geom_histogram(bins = 20, 
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

# PREPARE DATA FOR COVARIANCE AND CORRELATION
library(dplyr)
selected_data = df %>% select(starts_with("i"))
View(selected_data)

#COVARIANCE
cov_matrix = cov(selected_data)
print(cov_matrix)

# prepare matrix to be ploted as heatmap
melted_cov = melt(cov_matrix)
melted_cov$Var1 <- as.factor(melted_cov$Var1)
melted_cov$Var2 <- as.factor(melted_cov$Var2)
melted_cov$value <- as.numeric(melted_cov$value)

#plot the matrix
ggplot(data = melted_cov, aes(x = Var1, y= Var2, fill = value)) +
  geom_tile() + 
  scale_fill_gradient2(low = "blue", 
                       high = "red", 
                       mid = "white",
                       midpoint = median(melted_cov$value), 
                       limit = c(min(melted_cov$value), max(melted_cov$value)), 
                       space="Lab",
                       name="Covariance\n of FTIR spectra") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, 
                                   vjust = 1, 
                                   size = 12, 
                                   hjust = 1)) +
  coord_fixed()

# CORRELATION
# make correlation matrix
cor_matrix = cor(selected_data)
print(cor_matrix)

# t-test for the matrix
library(Hmisc)
rcorr(as.matrix(selected_data))

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
                       midpoint = 0.90, # first set median(melted_cor$value), then change
                       limit = c(min(melted_cor$value), max(melted_cor$value)), 
                       space="Lab",
                       name="Pearson correlation\n of FTIR spectra") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 90, 
                                   vjust = 1, 
                                   size = 12, 
                                   hjust = 1)) +
  coord_fixed()


# DIFFERENTIATE SPECIIC SPECTRA
library(ggplot2)

# Highlight specific spectra 
highlight_spectra = "i20"

# Base plot
plot = ggplot(df_long, aes(x = wavenumber, y = value, color = variable)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Multiple Intensity Variables Against Wavelength",
       x = "Wavelength",
       y = "Intensity",
       color = "Variable") +
  theme(plot.title = element_text(hjust = 0.5))

# subplot
plot = plot +
  geom_line(data = subset(df_long, variable == highlight_spectra),
            aes(x = wavenumber, 
                y = value, 
                color = variable),
                size = 0.75) + # Customize size and linetype
  scale_color_manual(values = setNames(c("red", 
                                         rep("grey50", 
                                             length(unique(df_long$variable)) - 1)), 
                                       c(highlight_spectra, 
                                         setdiff(unique(df_long$variable), 
                                                 highlight_spectra))))

print(plot)
