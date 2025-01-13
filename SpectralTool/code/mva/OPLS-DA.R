# load libraries
library(ggplot2)
library(ropls)
library(prospectr)
library(gridExtra)
library(pracma)


# load dataset
oplsda.df <- read.csv(file.choose())
View(oplsda.df)

# make numeric dataset for Kennard-Stone
# subset the dataframe
cat(paste(seq_along(colnames(oplsda.df)[1:25]), colnames(oplsda.df)[1:25], sep = ". "), sep = "\n")
df.numeric <- oplsda.df[, 3:ncol(oplsda.df)]
#View(df.numeric)

# declare class and names
class <- oplsda.df[, 2]
dataMatrix <- oplsda.df[, 3:dim(oplsda.df)[2]]

#check class and data matrix
#View(class)
#View(dataMatrix)


####################################
# Dataset division - Kennard-Stone #
####################################

# enter percetage of dataset to be used for training
t <- 0.8

#----------------------------- run together -----------------------------------#
# determine number 
k <- round((nrow(df.numeric) * t), 0)

# run Kennard-Stone function
kennard.euclid <- kenStone(df.numeric, k, metric = 'euclid')

# subset original dataframe
train.vector <- kennard.euclid$model
#------------------------------------------------------------------------------#
#################
# Run the model #
#################

#------------------------------ run together ----------------------------------#
#start timer
start_time <- Sys.time()

# number of permutation - double the size of sample
n.perm <- 2*nrow(oplsda.df)

# run opls function with default graphs
data.oplsda <- opls(dataMatrix, 
                    class, 
                    predI = NA, 
                    orthoI = NA,
                    #subset = train.vector, 
                    permI = n.perm
                    )

# stop the timer and display time elapsed
end_time <- Sys.time()
elapsed_time <- end_time - start_time
elapsed_time
#------------------------------------------------------------------------------#

####################
# Plot the results #
####################

par(mfrow = c(1, 2))
#plot of x-score
plot(data.oplsda,
     typeVc = "x-score")
# plot of x-score
plot(data.oplsda,
     typeVc = "permutation")

####################
# Rainbow spectrum #
####################

# get loadings
loadings <- getLoadingMN(data.oplsda)
loadings.and.vips <- as.data.frame(loadings)
loadings.and.vips$p1 <- as.numeric(loadings.and.vips$p1)

# get VIP scores
vip <- getVipVn(data.oplsda)
vip <- as.data.frame(vip)

loadings.and.vips["vip"] <- vip$vip
loadings.and.vips$vip <- as.numeric(loadings.and.vips$vip)


df.transposed <- as.data.frame(t(df.numeric))
df.transposed$Wavenumber <- rownames(df.transposed)
df.transposed <- df.transposed[c("Wavenumber", setdiff(names(df.transposed), "Wavenumber"))]
df.transposed$Wavenumber <- sub("^X", "", df.transposed$Wavenumber)
df.transposed$Wavenumber <- as.numeric(df.transposed$Wavenumber)
View(df.transposed)

wavenumber <- df.transposed$Wavenumber

df.transposed[, -1] <- lapply(df.transposed[, -1], as.numeric)
mean_intensities <- rowMeans(df.transposed[, -1])

mean_spectra <- data.frame(Wavenumber = wavenumber, Intensity = mean_intensities)

mean_spectra$Wavenumber <- as.numeric(mean_spectra$Wavenumber)


# peak picking
mean_spectra_fp <- findpeaks(mean_spectra$Intensity,
                             minpeakheight = -1,
                             minpeakdistance = 30,)
mean_spectra_fp

mean_spectra_pi <- mean_spectra_fp[, 2]
mean_spectra_peaks <- data.frame(
  Wavenumber = mean_spectra$Wavenumber[mean_spectra_pi],
  Intensity = mean_spectra_fp[, 1])

ylim_min <- -1.3
ylim_max <- 4
intensity_offset <- 0.3

par(mfrow = c(1, 2))

loadings.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(loadings.and.vips$p1))) +
  scale_color_gradient(limits = c(median(loadings.and.vips$p1),
                                  max(loadings.and.vips$p1)),
                       low="green",
                       high="red") +
  geom_segment(data = mean_spectra_peaks, aes(x = Wavenumber, xend = Wavenumber, 
                                              y = Intensity + intensity_offset, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + intensity_offset,  # Adjust position above the notch
                                           label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = "Value of loadings in the first component",
       x = "Wavenumber",
       y = "Intensity",
       color = "Loadings value") +
  scale_x_reverse() +
  ylim(ylim_min, ylim_max) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5)) 

loadings.rainbow.plot


vips.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(loadings.and.vips$vip))) +
  scale_color_gradient(limits = c(min(loadings.and.vips$vip),
                                  max(loadings.and.vips$vip)),
                       low="green",
                       high="red") +
  geom_segment(data = mean_spectra_peaks, aes(x = Wavenumber, xend = Wavenumber, 
                                              y = Intensity + intensity_offset, yend = Intensity),  # Small vertical lines
               color = "red", size = 1) +  # Adjust size for thickness of notches
  
  # Add vertical text labels for the peaks directly on top of the notches
  geom_text(data = mean_spectra_peaks, aes(x = Wavenumber, y = Intensity + intensity_offset,  # Adjust position above the notch
                                           label = round(Wavenumber, 0)), 
            angle = 90, vjust = 0, hjust = 0, color = "black") +
  labs(title = "VIP values",
       x = "Wavenumber",
       y = "Intensity",
       color = "VIP value") +
  scale_x_reverse() +
  ylim(ylim_min, ylim_max) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5)) 

vips.rainbow.plot
