# load libraries
library(ggplot2)
library(ropls)
library(prospectr)
library(gridExtra)
library(pracma)
library(reshape2)

# User input -------------------------------------------------------------------

# Load dataset
oplsda.df <- read.csv(file.choose())
View(oplsda.df)

# Specify the row number of the class column and the first row of the data
class.row.no <- 2
data.first.row <- 3

# Enter the part of the dataset to be used for training
t <- 0.8

# Enter limits of y-axis on Rainbow Spectrum and offset of wavenumber markers
ylim_min <- -1.3
ylim_max <- 4
intensity_offset <- 0.3


# Dataset preparation ----------------------------------------------------------

# Declare class and names
class <- oplsda.df[, class.row.no]
dataMatrix <- oplsda.df[, data.first.row:dim(oplsda.df)[2]]

# Make numeric dataset for Kennard-Stone
df.numeric <- oplsda.df[, data.first.row:ncol(oplsda.df)]


# Dataset division - Kennard-Stone ---------------------------------------------

# Determine number 
k <- round((nrow(df.numeric) * t), 0)

# Sun Kennard-Stone function
kennard.euclid <- kenStone(df.numeric, k, metric = 'euclid')

# Subset original dataframe
train.vector <- kennard.euclid$model


# Run the OPLS-DA model --------------------------------------------------------

# Start timer
start_time <- Sys.time()

# Number of permutation - double the size of sample
n.perm <- 2*nrow(oplsda.df)

# Run OPLS-DA model with permutation test
data.oplsda <- opls(
  dataMatrix,
  class,
  predI = NA,
  orthoI = NA,
  permI = n.perm,
  subset = NULL
)

# Run OPLS-DA model with training
data.oplsda.subset <- opls(
  dataMatrix,
  class,
  predI = NA,
  orthoI = NA,
  subset = train.vector,
  permI = 0
)

# Model summaries
data.oplsda@summaryDF
data.oplsda.subset@summaryDF

# Stop the timer and display time elapsed
end_time <- Sys.time()
elapsed_time <- end_time - start_time
elapsed_time


# Model plots ------------------------------------------------------------------

# Set plot layout
par(mfrow = c(1, 2))

# Plot of x-score
plot(data.oplsda, typeVc = "x-score")

# Plot of permutation test
plot(data.oplsda, typeVc = "permutation")


# Rainbow spectrum preparation -------------------------------------------------

# Get loadings
loadings <- getLoadingMN(data.oplsda)
loadings.and.vips <- as.data.frame(loadings)
loadings.and.vips$p1 <- as.numeric(loadings.and.vips$p1)

# Get VIP scores
vip <- getVipVn(data.oplsda)
vip <- as.data.frame(vip)

# Combine loadings and VIP scores
loadings.and.vips["vip"] <- vip$vip
loadings.and.vips$vip <- as.numeric(loadings.and.vips$vip)

# Transpose the dataset
df.transposed <- as.data.frame(t(df.numeric))

# Repair Wavenumber column
df.transposed$Wavenumber <- rownames(df.transposed)
df.transposed <- df.transposed[c("Wavenumber", setdiff(names(df.transposed), "Wavenumber"))]
df.transposed$Wavenumber <- sub("^X", "", df.transposed$Wavenumber)
df.transposed$Wavenumber <- as.numeric(df.transposed$Wavenumber)

# Calculate mean intensities
df.transposed[, -1] <- lapply(df.transposed[, -1], as.numeric)
mean_intensities <- rowMeans(df.transposed[, -1])

# Get wavenumbers and put together mean spectra dataframe
wavenumber <- df.transposed$Wavenumber
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

# Plot loadings on the Rainbow Spectrum ----------------------------------------

loadings.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(loadings.and.vips$p1))) +
  scale_color_gradient(
    limits = c(median(loadings.and.vips$p1), max(loadings.and.vips$p1)),
    low = "green",
    high = "red"
  ) +
  geom_segment(
    data = mean_spectra_peaks,
    aes(
      x = Wavenumber,
      xend = Wavenumber,
      y = Intensity + intensity_offset,
      yend = Intensity
    ),
    color = "red",
    size = 1
  ) +  
  geom_text(
    data = mean_spectra_peaks,
    aes(
      x = Wavenumber,
      y = Intensity + intensity_offset,
      label = round(Wavenumber, 0)
    ),
    angle = 90,
    vjust = 0,
    hjust = 0,
    color = "black"
  ) +
  labs(
    title = "Value of loadings in the first component",
    x = "Wavenumber",
    y = "Intensity",
    color = "Loadings value"
  ) +
  scale_x_reverse() +
  ylim(ylim_min, ylim_max) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5))


# Plot VIP scores on the Rainbow Spectrum --------------------------------------

vips.rainbow.plot <- ggplot(mean_spectra, aes(x = Wavenumber, y = Intensity, group = 1)) +
  geom_line(size = 1, aes(color = abs(loadings.and.vips$vip))) +
  scale_color_gradient(
    limits = c(min(loadings.and.vips$vip), max(loadings.and.vips$vip)),
    low = "green",
    high = "red"
  ) +
  geom_segment(
    data = mean_spectra_peaks,
    aes(
      x = Wavenumber,
      xend = Wavenumber,
      y = Intensity + intensity_offset,
      yend = Intensity
    ),
    color = "red",
    size = 1
  ) + 
  geom_text(
    data = mean_spectra_peaks,
    aes(
      x = Wavenumber,
      y = Intensity + intensity_offset,
      label = round(Wavenumber, 0)
    ),
    angle = 90,
    vjust = 0,
    hjust = 0,
    color = "black"
  ) +
  labs(
    title = "VIP values",
    x = "Wavenumber",
    y = "Intensity",
    color = "VIP value"
  ) +
  scale_x_reverse() +
  ylim(ylim_min, ylim_max) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        legend.title = element_text(hjust = 0.5))

# Plot Rainbow Spectra
loadings.rainbow.plot
vips.rainbow.plot

# Save model for later ---------------------------------------------------------
save(data.oplsda, file = "oplsda_model.RData")
