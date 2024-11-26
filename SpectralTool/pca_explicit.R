# set work directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets")

# read and inspect dataframe
df = read.csv('all_spectra_std_order_corr_test.csv')
View(df)

#load libraries
library(ggplot2)
library(dplyr)

#######################
#PREPROCESS DATAFRAMES#
#######################

# remove rows with 0, else scaling wont work
df = df[apply(df!=0, 1, all),]
View(df)

# tranpose
df_pca = t(df)

# make first row column names
colnames(df_pca) = as.character(unlist(df_pca[1, ]))

# replace previous column names and reset
df_pca = df_pca[-1, ]
rownames(df) = NULL

# inspect the results
View(df_pca)



##############################
#PRINCIPAL COMPONENT ANALYSIS#
##############################

# calculate PCs
results = prcomp(df_pca, scale=TRUE)
View(results)

# reverse eigenvectors
results$rotation = -1*results$rotation

# dispay PCs
results$rotation

#calculate total variance explained by each principal component
var_explained = results$sdev^2 / sum(results$sdev^2)
var_cumulative = cumsum(var_explained)
print(var_explained)
print(var_cumulative)

# make results dataframe
var_results = data.frame(PC = 1:length(var_explained),
                    ExplainedVariance = var_explained,
                    CumulativeVariance = var_cumulative)
#############
# SCREE PLOT#
#############

ggplot(var_results, aes(x = PC)) +
  geom_bar(aes(y = ExplainedVariance * 100), 
           stat = "identity", 
           fill = "steelblue") +
  geom_line(aes(y = CumulativeVariance * 100), 
            color = "red", 
            size = 1) +
  geom_point(aes(y = CumulativeVariance * 100), 
             color = "red", 
             size = 2) +
  labs(title = "Scree Plot",
       x = "Principal Component",
       y = "Percentage of Variance Explained") +
  theme_minimal() +
  scale_y_continuous(sec.axis = sec_axis(~ ., name = "Cumulative Variance Explained (%)")) +
  theme(plot.title = element_text(hjust = 0.5))


##########
# BIPLOTS#
##########

# automatic biplot
biplot(results, scale = 0)

# preparedataframes for manual biplot
scores = as.data.frame(results$x)
loadings = as.data.frame(results$rotation)
pca_df = data.frame(scores, Sample = rownames(scores))
loadings_df = data.frame(loadings, Variable = rownames(loadings))
View(loadings_df)

#manual biplot
ggplot() +
  geom_point(data = pca_df, aes(x = PC1, y = PC2, color = Sample), size = 2) +
  geom_segment(data = loadings_df, aes(x = 0, y = 0, xend = PC1 * 100, yend = PC2 * 100), 
               arrow = arrow(length = unit(0.2, "cm")), color = "red") +
  #geom_text(data = loadings_df, aes(x = PC1 * 120, y = PC2 * 120, label = Variable), 
            #color = "black", vjust = 1.5) +
  geom_text(data = pca_df, aes(x = PC1, y = PC2, label = Sample), 
            vjust = -0.5, hjust = 1.5, size = 3) +
  labs(title = "PCA Biplot",
       x = "Principal Component 1",
       y = "Principal Component 2") +
  theme_minimal()
theme(plot.title = element_text(hjust = 0.5))



###########################################
# EXPORT LOADINGS FOR USE IN RAINBOW CHART#
###########################################

# merge dataframes by row indices
print(df)
print(loadings_df)
rownames(loadings_df) = loadings_df$wavenumber
loadings_df$wavenumber = NULL
View(loadings_df)

output_df = merge(df, loadings_df, by = 0)
rownames(output_df) = NULL
arrange(output_df, wavenumber)
View(output_df)

write.csv(output_df, "loadings_for_rainbow.csv", row.names = FALSE)

