# set work directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/procrustes")

# read and inspect dataframe
df_1 = read.csv('master_omnic.csv')
View(df_1)

df_2 = read.csv('master_openspecy.csv')
View(df_2)

#load libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(gridExtra)
library(vegan)
library(ade4)

###########################
# VISUALY INSPECT SPECTRA #
###########################

# plot the all spectral lines - df_1
df1_long = pivot_longer(df_1, cols = starts_with("Std_"), 
                       names_to = "variable", 
                       values_to = "value")

plot_1 = ggplot(df1_long, aes(x = wavenumber, y = value, color = variable)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Spectra processed in OMNIC",
       x = "Wavelength",
       y = "Intensity",
       color = "Variable") +
  theme(plot.title = element_text(hjust = 0.5))

# plot the all spectral lines - df_2
df2_long = pivot_longer(df_2, cols = starts_with("Std_"), 
                        names_to = "variable", 
                        values_to = "value")

plot_2 = ggplot(df2_long, aes(x = wavenumber, y = value, color = variable)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Spectra processed in OpenSpecy",
       x = "Wavelength",
       y = "Intensity",
       color = "Variable") +
  theme(plot.title = element_text(hjust = 0.5))

grid.arrange(plot_1, plot_2, ncol = 2)


###############################
#PREPROCESS DATAFRAMES FOR PCA#
###############################

# remove rows with 0, else scaling wont work
df_1 = df_1[apply(df_1!=0, 1, all),]
df_2 = df_2[apply(df_2!=0, 1, all),]

# tranpose
df1_pca = t(df_1)
df2_pca = t(df_2)

# make first row column names
colnames(df1_pca) = as.character(unlist(df1_pca[1, ]))
colnames(df2_pca) = as.character(unlist(df2_pca[1, ]))

# replace previous column names and reset
df1_pca = df1_pca[-1, ]
rownames(df1_pca) = NULL

df2_pca = df2_pca[-1, ]
rownames(df2_pca) = NULL

# inspect the results
View(df1_pca)
View(df2_pca)


###################
# PERFORM THE PCA #
###################

# calculate PCs
results_1 = prcomp(df1_pca, scale=TRUE)
results_2 = prcomp(df2_pca, scale = TRUE)

# reverse eigenvectors
results_1$rotation = -1*results_1$rotation
results_2$rotation = -1*results_2$rotation

# dispay PCs
results_1$rotation
results_2$rotation

# automatic biplot
biplot_1 = biplot(results_1, scale = 0)
biplot_2 = biplot(results_2, scale = 0)
grid.arrange(biplot_1, biplot_2, ncol = 2)


###############################
# PERFORM PROCRUSTES ANALYSIS #
###############################

# perform procrustes analyses
pro = procrustes(X = results_1, Y = results_2, symmetric = TRUE) 
print(pro)

# plot the results
plot(pro, kind = 1, type = "text")
plot(pro, kind = 2)

# perform procrustes randomization test
protest(X = results_1, Y = results_2, scores = "sites", permutations = 9999)
