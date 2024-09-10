# set work directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/preprocessed spectra")

# read and inspect dataframe
df_1 = read.csv('DPP1_all.csv')
View(df_1)

df_2 = read.csv('DPP2_all.csv')
View(df_2)

df_3 = read.csv("DPP3_all.csv")

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


#################################
# PREPROCESS DATAFRAMES FOR PCA #
#################################

# remove rows with 0, else scaling wont work
df_1 = df_1[apply(df_1!=0, 1, all),]
df_2 = df_2[apply(df_2!=0, 1, all),]
df_3 = df_3[apply(df_3!=0, 1, all),]

# tranpose
df1_pca = t(df_1)
df2_pca = t(df_2)
df3_pca = t(df_3)

# make first row column names
colnames(df1_pca) = as.character(unlist(df1_pca[1, ]))
colnames(df2_pca) = as.character(unlist(df2_pca[1, ]))
colnames(df3_pca) = as.character(unlist(df3_pca[1, ]))

# replace previous column names and reset
df1_pca = df1_pca[-1, ]
rownames(df1_pca) = NULL

df2_pca = df2_pca[-1, ]
rownames(df2_pca) = NULL

df3_pca = df3_pca[-1, ]
rownames(df3_pca) = NULL

# inspect the results
View(df1_pca)
View(df2_pca)
View(df3_pca)

###################
# PERFORM THE PCA #
###################

# calculate PCs
results_1 = prcomp(df1_pca, scale=TRUE)
results_2 = prcomp(df2_pca, scale = TRUE)
results_3 = prcomp(df3_pca, scale = TRUE)

# reverse eigenvectors
results_1$rotation = -1*results_1$rotation
results_2$rotation = -1*results_2$rotation
results_3$rotation = -1*results_3$rotation

# dispay PCs
results_1$rotation
results_2$rotation
results_3$rotation

# automatic biplot
par(mfrow = c(1, 3))

biplot(results_1, scale = 0)
title(main = "DPP1", line = 2.5)  # Adjust the value of 'line' to move the title

biplot(results_2, scale = 0)
title(main = "DPP2", line = 2.5)

biplot(results_3, scale = 0)
title(main = "DPP3", line = 2.5)

###############################
# PERFORM PROCRUSTES ANALYSIS #
###############################

# perform procrustes
pro = procrustes(X = results_2, 
                 Y = results_3, 
                 symmetric = TRUE, 
                 scale = TRUE) 
# print the results
print(pro)

# remove "site" part of labels
labels = rownames(pro$X)
labels = gsub("site", "", labels)

# plot the results - two plots
par(mfrow = c(1, 2))
plot(pro, kind = 1, type = "n")
plot(pro, kind = 2)

# plot the results - one plot
par(mfrow = c(1,1))
plot(pro)
text(pro$X, 
     labels = labels, 
     col = "black", 
     pos = 4, 
     cex = 0.6
)


#######################
# PERFORM MANTEL TEST #
#######################

# take out the scores from first two principal components
scores_1 = results_1$x[, 1:2]
scores_2 = results_2$x[, 1:2]
scores_3 = results_3$x[, 1:2]

# check the dimensions - matrices must be the same dimensions
dim(scores_1)
dim(scores_2)
dim(scores_3)

# make distance matrix from derived scores
dist_1 = dist(scores_1)
dist_2 = dist(scores_2)
dist_3 = dist(scores_3)

# perform the Mantel test
mantel_result = mantel(dist_2, 
                       dist_3, 
                       method = "pearson",
                       permutations = 9999)
print(mantel_result)



