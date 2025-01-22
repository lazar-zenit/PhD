#  Load libraries -------------------------------------------------------------
library(ggplot2)
library(FactoMineR)
library(factoextra)
library(tidyr)
library(gridExtra)
library(pracma)
library(dplyr)
library(svglite) # if you wish to save images automaticaly


# User input ------------------------------------------------------------------

# Load prepared dataset in .csv format
df <- read.csv(file.choose(), check.names = FALSE)

# Filter dataframe if you need
#df <- df %>%
  #filter(Type == "Treatment")

# Inspect dataframe and decide which columns go into PCA
#View(df)

# Specify first column of numerical data
first.data.col <- 6

# subset the dataframe
df.active <- df[, first.data.col:ncol(df)]

# inspect active dataframe
#View(df.active)

# Limit number of principal components to be displayed in scree plot
scree.pc.lim <- 20

# Number of permutations for PCA permutation test
n_permutations <- 500 

# Y-axis limits on Rainbow Spectrum and offset of wavenumber markers
ylim_min <- -0.1
ylim_max <- 2
intensity_offset <- 0.3


# PCA (FactoMineR) ------------------------------------------------------------

# Perform PCA
pca.results <- PCA(df.active, graph = FALSE)

# Print the results of PCA
print(pca.results)                                                            
                                                                              

# Score plots colored by category (FActoMineR) --------------------------------
colour.score.plot <- fviz_pca_ind(pca.results,
                                  addEllipses=TRUE,                                                  # these elipses are for categories
                                  ellipse.level=0.95,
                                  col.ind = as.factor(df$Type),                    # it is very important to do as. factor
                                  palette = c("#2C3E50", "#E74C3C")                       # if it were continous variabes no as.factor needed
) +                 
  labs(title = "Score plot at 70 h") +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom") 

colour.score.plot


  # Scree plot ------------------------------------------------------------------

# Get the eigenvalues from pca.results object
eig.vals <- get_eigenvalue(pca.results)

# Prepare eigenvlues so they can be used in ggplot2
eig.val.scree <- eig.vals
eig.val.scree <- as.data.frame(eig.val.scree)
eig.val.scree$dimensions <- 1:nrow(eig.val.scree)                             

# Inspect eigenvalues
eig.val.scree

# Make Scree plot (manually looks best)
scree_plot = ggplot(eig.val.scree, aes(x = dimensions)) +
  
  # Bars for variance explained
  geom_col(aes(y = variance.percent, fill = "Variance (%)"), alpha = 0.4) +
  
  # Points for variance explained
  geom_point(aes(y = variance.percent, color = "Variance (%)")) +
  
  # Line for variance explained
  geom_line(aes(y = variance.percent, color = "Variance explained (%)", group = 1)) +
  
  # Points for cumulative variance
  geom_point(aes(y = cumulative.variance.percent, color = "Cumulative Variance (%)")) +
  
  # Line for cumulative variance
  geom_line(aes(y = cumulative.variance.percent, color = "Cumulative Variance (%)", group = 2)) +
  
  # Text for variance explained
  geom_text(
    aes(y = variance.percent, label = round(variance.percent, 1)),
    hjust = -0.5,
    angle = 90,
    size = 3,
    color = "blue"
  ) +
  
  # Text for cumulative variance
  geom_text(
    aes(
      y = cumulative.variance.percent,
      label = round(cumulative.variance.percent, 1)
    ),
    hjust = 1.5,
    angle = 90,
    size = 3,
    color = "red"
  ) +
  
  # Labels
  labs(
    title = "Scree Plot",
    x = "Principal Components",
    y = "Percentage (%)",
    color = "Colour",
    fill = "Fill"
  ) +
  
  # Color scale
  scale_color_manual(values = c(
    "Variance explained (%)" = "blue",
    "Cumulative Variance (%)" = "red"
  )) +
  
  # X-axis is continous not factors
  scale_x_continuous(breaks = seq(1, max(eig.val.scree$dimensions), by = 1)) +
  
  # Y-axis limits
  ylim(0, 105) +
  xlim(1, scree.pc.lim) +
  theme_minimal() +
  theme(
    # Ajdust orientation of text
    axis.text.x = element_text(
      angle = 0,
      vjust = 0.5,
      hjust = 1
    ),
    plot.title = element_text(hjust = 0.5, vjust = 1.5)
  )

                                  
# Display the plot                                  
scree_plot

# Save the plot as .svg
#ggsave("scree_plot.svg", plot = scree_plot, width = 25, height = 20, units = "cm")


# Permutation test ------------------------------------------------------------

# Percent variance explaned in original data
orig_var_percent <- pca.results$eig[, 2]                                       

# Number of permutations and number of components to be calculated
n_components <- nrow(pca.results$eig)                                           
                                                                              

# Matrix to store permuted percentages of variance
perm_var_percent <- matrix(0, nrow = n_permutations, ncol = n_components)

# Random seed - can be un-commented for reproducibility
#set.seed(123)

# Do PCA n-permutation number of times
for (i in 1:n_permutations) {
  # Permute each column
  permuted_data <- apply(df.active, 2, sample)
  
  # Perform PCA
  perm_pca <- PCA(permuted_data, scale.unit = TRUE, graph = FALSE)
  
  # Extract % variance explained
  perm_var_percent[i, ] <- perm_pca$eig[, 2]
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

# Filter the dataframe to limit continous x-axis
orig_var_df <- orig_var_df %>%
  filter(Component >= 1 & Component <= scree.pc.lim)

# Convert user input to strings to limit discrete x-axis
x_discrete <- as.character(seq(1, scree.pc.lim))

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
  scale_color_manual(values = c("Original Data" = "red")) +
  scale_x_discrete(limits = c(x_discrete))


permutation_test_plot

#ggsave("permutation_test.svg", plot = permutation_test_plot, width = 25, height = 20, units = "cm")

#############
# Variables #
#############
var <- get_pca_var(pca.results)


# just loadings
fviz_pca_var(pca.results)

fviz_pca_ind(pca.results)

# loadings and scores
fviz_pca_biplot(pca.results)


# k-means clustering ---------------------------------------------------------

# set seed for reproducibility
set.seed(123)                                  


km.results <- kmeans(var$coord, # Number of centers (clusters)
                     centers = 3, # Number of random sets to begin with
                     nstart = 25)  

# Print results
km.results

# Cluster must be as factors for vizualization
grp <- as.factor(km.results$cluster)            

# Vizualize
fviz_pca_var(pca.results, 
             col.var = grp,
             pallete = c("#0073C2FF", "#EFC000FF", "#868686FF"),
             legend.title = "Cluster")


fviz_pca_ind(pca.results,                                                       # our PCA object
             geom.ind = "point",
             col.ind = df$`Label`,                                          # category pulled from original dataframe,
             pallete = c("#00AFBB", "#E7B800"),   
             addEllipses = TRUE,                                                # add elipses
             legend.title = "Groups") +  
  labs(title = "PCA") +
  theme(plot.title = element_text(hjust = 0.5))                                 # center the title


# RainbowSpectrum --------------------------------------------------------------

# Extract variable contribution to the total variance of component (in %)
contrib <- pca.results$var$contrib

# Convert it to dataframe
contrib_df <- as.data.frame(contrib)

# Add column with row names (not in column by default)
contrib_df$Variable <- rownames(contrib)

# Our active column is transposed for multivariate applications. we need to change it back
df.transposed <- as.data.frame(t(df.active))

# Add Wavenumber column
df.transposed$Wavenumber <- rownames(df.transposed)

# Put Wavenumber in first place
df.transposed <- df.transposed[c("Wavenumber", setdiff(names(df.transposed), "Wavenumber"))]

# Extract wavenumbers and calculate means of all the other columns
wavenumber <- df.transposed$Wavenumber

# Transpose table as numeric
df.transposed[, -1] <- lapply(df.transposed[, -1], as.numeric)

# Calulate mean intensities
mean_intensities <- rowMeans(df.transposed[, -1])

# Convert it to dataframe
mean_spectra <- data.frame(Wavenumber = wavenumber, Intensity = mean_intensities)
mean_spectra$Wavenumber <- as.numeric(mean_spectra$Wavenumber)

# Peak picking
mean_spectra_fp <- findpeaks(mean_spectra$Intensity,
                                minpeakheight = -1,
                             minpeakdistance = 30,)

mean_spectra_pi <- mean_spectra_fp[, 2]
mean_spectra_peaks <- data.frame(
  Wavenumber = mean_spectra$Wavenumber[mean_spectra_pi],
  Intensity = mean_spectra_fp[, 1])


# Get the percentage of variance explained by each component
pc1.var.per <- round(eig.val.scree$variance.percent[1], 1)
pc2.var.per <- round(eig.val.scree$variance.percent[2], 1)
pc3.var.per <- round(eig.val.scree$variance.percent[3], 1)
pc4.var.per <- round(eig.val.scree$variance.percent[4], 1)

# Plot the RainbowSpectrum 
pc1.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(contrib_df$Dim.1))) +
  scale_color_gradient(limits = c(min(contrib_df$Dim.1),
                                  max(contrib_df$Dim.1)),
                       low="green",
                       high="red") +
  geom_segment(data = mean_spectra_peaks, aes(x = Wavenumber, xend = Wavenumber, 
                                y = Intensity + intensity_offset, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + intensity_offset,  # Adjust position above the notch
                             label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = paste("Variable contribution to the PC1 ", "(", pc1.var.per, "% of total variance )"),
       x = "Wavenumber",
       y = "Intensity",
       color = "Contribution to \n the PC1 (%)") +
  #scale_x_reverse() +
  ylim(ylim_min, ylim_max) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5)) 

pc2.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(contrib_df$Dim.2))) +
  scale_color_gradient(limits = c(min(contrib_df$Dim.2),
                                  max(contrib_df$Dim.2)),
                       low="green",
                       high="red") +
  geom_segment(data = mean_spectra_peaks, aes(x = Wavenumber, xend = Wavenumber, 
                                              y = Intensity + intensity_offset, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + intensity_offset,  # Adjust position above the notch
                                           label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = paste("Variable contribution to the PC2 ", "(", pc2.var.per, "% of total variance )"),
       x = "Wavenumber",
       y = "Intensity",
       color = "Contribution to \n the PC2 (%)") +
  #scale_x_reverse() +
  ylim(ylim_min, ylim_max) +
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
                                              y = Intensity + intensity_offset, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + intensity_offset,  # Adjust position above the notch
                                           label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = paste("Variable contribution to the PC3 ", "(", pc3.var.per, "% of total variance )"),
       x = "Wavenumber",
       y = "Intensity",
       color = "Contribution to \n the PC3 (%)") +
  #scale_x_reverse() +
  ylim(ylim_min, ylim_max) +
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
                                              y = Intensity + intensity_offset, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + intensity_offset,  # Adjust position above the notch
                                           label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = paste("Variable contribution to the PC4 ", "(", pc4.var.per, "% of total variance )"),
       x = "Wavenumber",
       y = "Intensity",
       color = "Contribution to \n the PC4 (%)") +
  #scale_x_reverse() +
  ylim(ylim_min, ylim_max) +
  theme_minimal() +s
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5)) 


# Combine all 4 plots
combine.rainbow <- grid.arrange(pc1.rainbow.plot, 
                                pc2.rainbow.plot, 
                                pc3.rainbow.plot, 
                                pc4.rainbow.plot,
                                ncol = 1)

# Save the plothttp://127.0.0.1:31339/graphics/65b8f076-501a-4552-a012-6854b72b5107.png
#ggsave("rainbow_plot.svg", plot = combine.rainbow, width = 21, height = 29.7, units = "cm")


