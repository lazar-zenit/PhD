# set the working directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/preprocessed spectra")

# load the libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

###################################
#       FROM LIST OF .CSVs        #
###################################
# make a list of files withing working directory
file_list = list.files(pattern = "*.CSV", full.names = TRUE)
print(file_list)

# make empty dataframes
data = data.frame()
all_data = data.frame()

# define function for reading .csv files
read_spectra = function(file_name) {
  data = read.csv(file_name)
  data_frame = as.data.frame(data)
  colnames(data_frame) = c("wavenumber", "intensity")
  data_frame$File = file_name
  return(data_frame)
}

# read all .csv files in the list
for (file in file_list) {
  data = read_spectra(file)
  all_data = bind_rows(all_data, data)
}

write.csv(all_data, "omnic_processed_all.csv", row.names=FALSE)

#############################################
# FROM SEPARATE FILES WITH MULTIPLE SPECTRA #
#############################################

#load the spectra
dpp1 <- read.csv("DPP1_all.csv")
dpp2 <- read.csv("DPP2_all.csv")
dpp3 <- read.csv("DPP3_all.csv")

# reshape the dataframes (pivot)
dpp1_long <- gather(dpp1, key = "Sample",
                    value = "Intensity",
                    starts_with("Std_")
                    )

dpp2_long <- gather(dpp2, key = "Sample",
                    value = "Intensity",
                    starts_with("Std_")
                    )

dpp3_long <- gather(dpp3, key = "Sample",
                    value = "Intensity",
                    starts_with("Std_")
                    )
# make the plots
dpp1_plot <- ggplot(dpp1_long,
                    aes(x = Wavenumber, 
                        y = Intensity, 
                        group = Sample,
                        color = Sample)) +
  geom_line() +
  ggtitle("SpectraGryph (DPP1)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5))

dpp1_plot


dpp2_plot <- ggplot(dpp2_long,
                    aes(x = Wavenumber, 
                        y = Intensity, 
                        group = Sample,
                        color = Sample)) +
  geom_line() +
  ggtitle("Openspecy webapp (DPP2)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5))

dpp2_plot


dpp3_plot <- ggplot(dpp3_long,
                    aes(x = Wavenumber, 
                        y = Intensity, 
                        group = Sample,
                        color = Sample)) +
  geom_line() +
  ggtitle("Openspecy in R (DPP3)") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5))

dpp3_plot

combined_plot <- dpp1_plot + dpp2_plot + dpp3_plot + plot_layout(ncol = 3)

combined_plot


# plot spectra a top of one another
ggplot(all_data, aes(x = wavenumber, y = intensity, color = File)) +
  geom_line() +
  theme_minimal() + 
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    plot.title = element_text(hjust = 0.5)
  ) +
  labs(title = "ATR-FTIR spectra processed with OMNIC (DPP1)",
       x = "Wavenumber",
       y = "Intensity")

# plot spectra individualy on one canvas
ggplot(all_data, aes(x = wavenumber, y = intensity, color = File)) +
  geom_line() +
  theme_minimal() + 
  facet_wrap(~ File, scales = "free_y") +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    plot.title = element_text(hjust = 0.5)
  ) +
  labs(title = "ATR-FTIR spectra processed with OMNIC",
       x = "Wavenumber",
       y = "Intensity")

