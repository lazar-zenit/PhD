################################################################################
#                                Libraries                                     #
################################################################################

library(ggplot2)
library(FactoMineR)
library(factoextra)
library(tidyr)
library(gridExtra)
library(pracma)

# other dependencies include: svglite (for saving images)

################################################################################
#                          Prepare the dataset                                 #
################################################################################

# load prepared dataset in .csv format
df <- read.csv(file.choose(), check.names = FALSE)                              # omnic_processed_all_pretty_MV_table.csv for test

# inspect dataframe and decide which columns go into PCA
View(df)

# subset the dataframe
df.active <- df[, 13:ncol(df)]                                                  # in this example we need column 1 
                                                                                # and column 13 to the end
# inspect active dataframe
View(df.active)


################################################################################
#                          perform PCA (FactoMineR)                           #
################################################################################

pca.results <- PCA(df.active, graph = TRUE)                                     # graph = TRUE is just for check, it is useless with
                                                                                # this much data
# print the results of PCA
print(pca.results)                                                              # results contain eigenvalues,  
                                                                                # coordinates, correlations, weights and much more
pca.results$eig
################################################################################
#                              PCA results                                     #
################################################################################

##############
# Scree plot #
##############

# get the eigenvalues from pca.results object
eig.vals <- get_eigenvalue(pca.results)

# prepare eigenvlues so they can be used in ggplot2
eig.val.scree <- eig.vals                                                       # make new variable for our plot
eig.val.scree <- as.data.frame(eig.val.scree)                                   # convert it to dataframe
eig.val.scree$dimensions <- 1:nrow(eig.val.scree)                               # add new column for dimensions

# inspecr eigenvalues
eig.val.scree

# make Scree plot (manualy making it looks best)
scree_plot = ggplot(eig.val.scree, aes(x = dimensions)) +
  
  # bars for varieance explained
  geom_col(aes(y = variance.percent, 
               fill = "Variance (%)"), 
           alpha = 0.4) +
  
  # points for variance explained
  geom_point(aes(y = variance.percent,                                          
                 color = "Variance (%)")) +
  
  # line for variance explained
  geom_line(aes(y = variance.percent,                                          
                color = "Variance explained (%)", group = 1)) +
  
  # points for cumulative variance
  geom_point(aes(y = cumulative.variance.percent,          
                 color = "Cumulative Variance (%)")) +
  
  # line for cumulative variance
  geom_line(aes(y = cumulative.variance.percent,           
                color = "Cumulative Variance (%)", 
                group = 2)) +
  
  # text for variance explained
  geom_text(aes(y = variance.percent,                      
                label = round(variance.percent, 1)), 
            hjust = -0.5,
            angle = 90,
            size = 3,
            color = "blue") +
  
  # text for cumulative variance
  geom_text(aes(y = cumulative.variance.percent,           
                label = round(cumulative.variance.percent, 1)), 
            hjust = 1.5,
            angle = 90,
            size = 3,
            color = "red") +
  
  # labels
  labs(title = "Scree Plot",                               
       x = "Principal Components", 
       y = "Percentage (%)",
       color = "Colour",
       fill = "Fill") +
  scale_color_manual(values = c("Variance explained (%)" = "blue",  
                                "Cumulative Variance (%)" = "red")) +
  scale_x_continuous(breaks = seq(1, max(eig.val.scree$dimensions), by = 1)) + 
  ylim(0, 105) +                                          
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 0,            
                                   vjust = 0.5, 
                                   hjust = 1),
        plot.title = element_text(hjust = 0.5,
                                  vjust = 1.5)
        )

                                  
# display the plot                                  
scree_plot

# save the plot as .svg
ggsave("scree_plot.svg", plot = scree_plot, width = 25, height = 20, units = "cm")


####################
# Permutation test #
####################

# percent variance explaned in original data
orig_var_percent <- pca.results$eig[, 2]                                        # extract percentage of variance

# number of permutations and number of components to be calculated
n_permutations <- 1000                                               
n_components <- nrow(pca.results$eig)                                           # number of components is equal to
                                                                                # number of eigenvalues

# matrix to store permuted percetages of variance
perm_var_percent <- matrix(0, nrow = n_permutations, ncol = n_components)

# radnom seed - can be uncommented for reproducibility
#set.seed(123)

# do pca n-permutation number of times
for (i in 1:n_permutations) {
  permuted_data <- apply(df.active, 2, sample)                                  # permute each column
  perm_pca <- PCA(permuted_data, scale.unit = TRUE, graph = FALSE)              # perform PCA
  perm_var_percent[i, ] <- perm_pca$eig[, 2]                                    # extract % variance explained
}

# Prepare data for ggplot
perm_var_df <- data.frame(
  Component = rep(1:n_components, times = n_permutations),
  Variance = as.vector(perm_var_percent)
)

orig_var_df <- data.frame(
  Component = 1:n_components,
  Variance = orig_var_percent
)


# Plotting                                  
permutation_test_plot = ggplot() +
  # Permuted data distribution
  geom_boxplot(data = perm_var_df, 
               aes(x = factor(Component), 
                   y = Variance,
                   fill = "Permuted Data"),
               alpha = 0.5, 
               outlier.shape = NA, 
               show.legend = TRUE
  ) +
  
  # Original data line
  geom_line(data = orig_var_df, 
            aes(x = Component, 
                y = Variance,
                color = "Original Data"), 
  ) +
  
  
  geom_point(data = orig_var_df, 
             aes(x = Component, 
                 y = Variance,
                 color = "Original Data"),
  ) +
  labs(
    title = "PCA Permutation Test",
    x = "Principal Component",
    y = "Variance Explained (%)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5,            # orientation and size of title
                                  vjust = 1.5),
        legend.title = element_blank()
  ) +
  scale_fill_manual(values = c("Permuted Data" = "lightblue")) +
  scale_color_manual(values = c("Original Data" = "red")) 


permutation_test_plot

ggsave("permutation_test.svg", plot = permutation_test_plot, width = 25, height = 20, units = "cm")

#############
# Variables #
#############
var <- get_pca_var(pca.results)


# just loadings
fviz_pca_var(pca.results)

# loadings and scores
fviz_pca_biplot(pca.results)

############
# Clusters #
############

# ths is done through K-means clustering
set.seed(123)                                   # set seed for reproducibility


km.results <- kmeans(var$coord,                 # we use coordinates
                     centers = 3,               # for k-means we need number of centers
                     nstart = 25)               # number of random sets to begin with              

km.results

grp <- as.factor(km.results$cluster)            # cluster must be as factors for vizualization

# vizualize
fviz_pca_var(pca.results, 
             col.var = grp,
             pallete = c("#0073C2FF", "#EFC000FF", "#868686FF"),
             legend.title = "Cluster")


fviz_pca_ind(pca.results,                                                       # our PCA object
             geom.ind = "point",
             col.ind = df$`Run order`,                                          # category pulled from original dataframe,
             pallete = c("#00AFBB", "#E7B800", "#FC4E07"),   
             addEllipses = TRUE,                                                # add elipses
             legend.title = "Groups") +                                         # title of legend
  theme(plot.title = element_text(hjust = 0.5))                                 # center the title

###################################
# Score plots colored by category #
###################################
temperature_score <- fviz_pca_ind(pca.results,
             addEllipses=TRUE,                                                  # these elipses are for categories
             ellipse.level=0.95,
             col.ind = as.factor(df$`Temperature (actual)`),                    # it is very important to do as. factor
             palette = c("#00AFBB", "#E7B800", "#FC4E07")                       # if it were continous variabes no as.factor needed
             ) +                 
  labs(title = "Score plot colored by temperature") +
  theme(plot.title = element_text(hjust = 0.5)) 

temperature_score

ethanol_score <- fviz_pca_ind(pca.results,
                              addEllipses=TRUE, 
                              ellipse.level=0.95,
                              col.ind = as.factor(df$`Percent ethanol (actual)`),
                              palette = c("#00AFBB", "#E7B800", "#FC4E07") ) +
  labs(title = "Score plot colored by percentage of ethanol") +
  theme(plot.title = element_text(hjust = 0.5)) 

ethanol_score


################################################################################
#                             RainbowSpectrum                                  #
################################################################################
# extract variable contribution to the total variance of component (in %)
contrib <- pca.results$var$contrib

# convert it to dataframe
contrib_df <- as.data.frame(contrib)

# add column with rown names (not in column by default)
contrib_df$Variable <- rownames(contrib)

# our active column is transposed for multivariate applications. we need to change it back
df.transposed <- as.data.frame(t(df.active))

# add Wavenumber column
df.transposed$Wavenumber <- rownames(df.transposed)

# put Wavenumber in first place
df.transposed <- df.transposed[c("Wavenumber", setdiff(names(df.transposed), "Wavenumber"))]

# extract wavenumbers and calculate means of all the other columns
wavenumber <- df.transposed$Wavenumber

df.transposed[, -1] <- lapply(df.transposed[, -1], as.numeric)
mean_intensities <- rowMeans(df.transposed[, -1])

mean_spectra <- data.frame(Wavenumber = wavenumber, Intensity = mean_intensities)
View(mean_spectra)

mean_spectra$Wavenumber <- as.numeric(mean_spectra$Wavenumber)

# peak picking
mean_spectra_fp <- findpeaks(mean_spectra$Intensity,
                                minpeakheight = 0.01)
mean_spectra_fp

mean_spectra_pi <- mean_spectra_fp[, 2]
mean_spectra_peaks <- data.frame(
  Wavenumber = mean_spectra$Wavenumber[mean_spectra_pi],
  Intensity = mean_spectra_fp[, 1])

# plot the RainbowSpectrum 
pc1.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(contrib_df$Dim.1))) +
  scale_color_gradient(limits = c(min(contrib_df$Dim.1),
                                  max(contrib_df$Dim.1)),
                       low="green",
                       high="red") +
  geom_segment(data = mean_spectra_peaks, aes(x = Wavenumber, xend = Wavenumber, 
                                y = Intensity + 0.02, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + 0.02,  # Adjust position above the notch
                             label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = "Variable contribution to the PC1",
       x = "Wavenumber",
       y = "Intensity",
       color = "Contribution to \n the PC1 (%)") +
  scale_x_reverse() +
  ylim(0, 1.15) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5)) 

pc1.rainbow.plot

pc2.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(contrib_df$Dim.2))) +
  scale_color_gradient(limits = c(min(contrib_df$Dim.2),
                                  max(contrib_df$Dim.2)),
                       low="green",
                       high="red") +
  geom_segment(data = mean_spectra_peaks, aes(x = Wavenumber, xend = Wavenumber, 
                                              y = Intensity + 0.02, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + 0.02,  # Adjust position above the notch
                                           label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = "Variable contribution to the PC2",
       x = "Wavenumber",
       y = "Intensity",
       color = "Contribution to \n the PC2 (%)") +
  scale_x_reverse() +
  ylim(0, 1.15) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5)) 

pc3.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(contrib_df$Dim.3))) +
  scale_color_gradient(limits = c(min(contrib_df$Dim.3),
                                  max(contrib_df$Dim.3)),
                       low="green",
                       high="red") +
  geom_segment(data = mean_spectra_peaks, aes(x = Wavenumber, xend = Wavenumber, 
                                              y = Intensity + 0.02, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + 0.02,  # Adjust position above the notch
                                           label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = "Variable contribution to the PC3",
       x = "Wavenumber",
       y = "Intensity",
       color = "Contribution to \n the PC3 (%)") +
  scale_x_reverse() +
  ylim(0, 1.15) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5)) 

pc4.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(contrib_df$Dim.4))) +
  scale_color_gradient(limits = c(min(contrib_df$Dim.4),
                                  max(contrib_df$Dim.4)),
                       low="green",
                       high="red") +
  geom_segment(data = mean_spectra_peaks, aes(x = Wavenumber, xend = Wavenumber, 
                                              y = Intensity + 0.02, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + 0.02,  # Adjust position above the notch
                                           label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = "Variable contribution to the PC4",
       x = "Wavenumber",
       y = "Intensity",
       color = "Contribution to \n the PC4 (%)") +
  scale_x_reverse() +
  ylim(0, 1.15) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5)) 


combine.rainbow <- grid.arrange(pc1.rainbow.plot, 
                                pc2.rainbow.plot, 
                                pc3.rainbow.plot, 
                                pc4.rainbow.plot,
                                ncol = 1)

ggsave("rainbow_plot.svg", plot = combine.rainbow, width = 21, height = 29.7, units = "cm")

pca.results

