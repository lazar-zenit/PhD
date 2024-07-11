#setup work directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets")

#import libraries
library(ggplot2)
library(dplyr)
library(scales)
library(patchwork)

df = read.csv("loadings_for_rainbow.csv")
View(df)


#sort
df <- df %>% arrange(wavenumber)

# make mean intensity column
df$mean_intensity <- rowMeans(df[, grep("^i\\d+$", names(df))])

# check the mean spectre
plot(df$wavenumber, df$mean_intensity, type="l")

# make sure everything is numeric
df[] = lapply(df, as.numeric)

# Distribution of loadings - p1
par(mfrow = c(1,1))
hist(df$PC1, freq = FALSE)
dens1 = density(df$PC1)
lines(dens1, lwd=2, col = "red")

# Distribution of loadings -p2
par(mfrow = c(1,1))
hist(df$PC2, freq = FALSE)
dens2 = density(df$PC2)
lines(dens2, lwd=2, col = "red")

# Distribution of loadings -p3
par(mfrow = c(1,1))
hist(df$PC3, freq = FALSE)
dens3 = density(df$PC3)
lines(dens3, lwd=2, col = "red")

# LOADINGS AND FTIR - UNSCALED
# p1
plot1_unscaled = ggplot(df, aes(x=wavenumber)) + 
  geom_bar(aes(y=PC1),
           stat = "identity",
           fill="red",
           width = 2) + 
  geom_line(aes(y = mean_intensity), 
            color = "black",
            size = 0.75)

# p2
plot2_unscaled = ggplot(df, aes(x=wavenumber)) + 
  geom_bar(aes(y=PC2),
           stat = "identity",
           fill="red",
           width = 2) + 
  geom_line(aes(y = mean_intensity), 
            color = "black",
            size = 0.75)

# p3
plot3_unscaled = ggplot(df, aes(x=wavenumber)) + 
  geom_bar(aes(y=PC3),
           stat = "identity",
           fill="red",
           width = 2) + 
  geom_line(aes(y = mean_intensity), 
            color = "black",
            size = 0.75)

# Combine and display plots
combined_plot_unscaled = plot1_unscaled / plot2_unscaled / plot3_unscaled
print(combined_plot_unscaled)

# LOADINGS AND FTIR - SCALED
# Spectrum and p1
mean_intensity_scaled_p1 =rescale(df$mean_intensity, 
                                  to = range(df$PC1, 
                                             na.rm = TRUE))
plot1 = ggplot(df, aes(x=wavenumber)) + 
  geom_bar(aes(y=PC1),
           stat = "identity",
           fill="red",
           width = 2) + 
  geom_line(aes(y = mean_intensity_scaled_p1), 
            color = "black",
            size = 0.75)

# Spectrum and p2
mean_intensity_scaled_p2 =rescale(df$mean_intensity, 
                                  to = range(df$PC2,
                                             na.rm = TRUE))
plot2 = ggplot(df, aes(x=wavenumber)) + 
  geom_bar(aes(y=PC2),
           stat = "identity",
           fill="red",
           width = 2) + 
  geom_line(aes(y = mean_intensity_scaled_p2), 
            color = "black",
            size = 0.75)

# Spectrum and p3
mean_intensity_scaled_p3 =rescale(df$mean_intensity, 
                                  to = range(df$PC3,
                                             na.rm = TRUE))
plot3 = ggplot(df, aes(x=wavenumber)) + 
  geom_bar(aes(y=PC3),
           stat = "identity",
           fill="red",
           width = 2) + 
  geom_line(aes(y = mean_intensity_scaled_p3), 
            color = "black",
            size = 0.75)

# Combine and display plots
combined_plot = plot1 / plot2 / plot3
print(combined_plot)

# RAINBOW PLOT
#p1
rainbow_plot_1 = ggplot(df, aes(x=wavenumber, y=mean_intensity)) +
geom_line(size=1.5, aes(colour = abs(PC1))) +
scale_color_gradient(limits = c(0, 
                                  abs(max(df$PC1))),
                       low="green",
                       high="red") +
labs(title = "Mean spectrum of experimental runs vs. PC1 loadings",
      x = "Wavenumber",
      y = "Apsorbance",
      color = "Absolute value of \n PC1 Loadings") 

#p2
rainbow_plot_2 = ggplot(df, aes(x=wavenumber, y=mean_intensity)) +
  geom_line(size=1.5, aes(colour = abs(PC2))) +
  scale_color_gradient(limits = c(0, 
                                  abs(max(df$PC2))),
                       low="green",
                       high="red") +
  labs(title = "Mean spectrum of experimental runs vs. PC2 loadings",
       x = "Wavenumber",
       y = "Apsorbance",
       color = "Absolute value of \n PC2 Loadings") 

#p3
rainbow_plot_3 = ggplot(df, aes(x=wavenumber, y=mean_intensity)) +
  geom_line(size=1.5, aes(colour = abs(PC3))) +
  scale_color_gradient(limits = c(0, 
                                  max(df$PC3)),
                       low="green",
                       high="red") +
  labs(title = "Mean spectrum of experimental runs vs. PC3 loadings",
       x = "Wavenumber",
       y = "Apsorbance",
       color = "Absolute value of \n PC3 Loadings") 


# Combine and display rainbow plots
combined_rainbow_plot = rainbow_plot_1 / rainbow_plot_2 / rainbow_plot_3
print(combined_rainbow_plot)

  