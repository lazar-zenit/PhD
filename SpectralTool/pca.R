# set work directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets")

# read and inspect dataframe
df = read.csv('central_points_bad.csv')
View(df)

# remove rows with 0, else scaling wont work
library(dplyr)
df = df[apply(df!=0, 1, all),]
View(df)

# TRANSPOSE DATAFRAME, TIDY UP AND INSPECT
# tranpose
df_pca = t(df)

# make first row column names
colnames(df_pca) = as.character(unlist(df_pca[1, ]))

# replace previous column names and reset
df_pca = df_pca[-1, ]
rownames(df) = NULL

# inspect the results
View(df_pca)


# CALCULATE PCs
results = prcomp(df_pca, scale=TRUE)

# reverse eigenvectors
results$rotation = -1*results$rotation

# dispay PCs
results$rotation

# biplot (useless in this case)
biplot(results, scale = 0)

#calculate total variance explained by each principal component
var_explained = results$sdev^2 / sum(results$sdev^2)

#create scree plot
qplot(c(1:6), var_explained) + 
  geom_line() + 
  xlab("Principal Component") + 
  ylab("Variance Explained") +
  ggtitle("Scree Plot") +
  ylim(0, 1)

library(ggplot2)

# Convert scores to a data frame
scores_df <- as.data.frame(results$x)

# Assuming you want to plot the first two principal components (PC1 and PC2)
ggplot(scores_df, aes(x = PC1, y = PC2)) +
  geom_point() +
  labs(x = "PC1", y = "PC2", title = "PCA Score Plot")
