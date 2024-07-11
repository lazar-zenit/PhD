# setup working directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/omnic_breakoff_input/csv files")

# load the libraries
library(OpenSpecy)
library(ggplot2)
library(dplyr)

###############
# IMPORT FILE #
###############
file_list = list.files(pattern = "*.CSV", full.names = TRUE)
print(file_list)

all_data_raw = data.frame()
all_data = data.frame()

#####################
# CHECK RAW SPECTRA #
#####################

# plot the raw data for inspection
read_raw_spectra = function(file_name) {
  data = read_text(file_name)
  data_frame = as.data.frame(data)
  colnames(data_frame) = c("wavenumber", "intensity")
  data_frame$File = file_name
  return(data_frame)
  
}

for (file in file_list) {
  raw_data = read_raw_spectra(file)
  all_data_raw = bind_rows(all_data_raw, raw_data)
}

ggplot(all_data_raw, aes(x = wavenumber, y = intensity, color = File)) +
  geom_line() +
  facet_wrap(~ File, scales = "free_y") +
  theme_minimal() + 
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    plot.title = element_text(hjust = 0.5)
  ) +
  labs(title = "Raw Spectral Data",
       x = "Wavenumber",
       y = "Intensity")

  
######################
# PROCESSING SPECTRA #
######################
process_spectra = function(file_name){
  data = read_text(file_name)
  
  # baseline correction
  data_1 = subtr_baseline(data,
                          type = "polynomial",
                          degree = 8,
                          raw = TRUE,
                          make_rel = TRUE
  ) 
  
  # smooth
  data_2 = smooth_intens(data_1,
                         polynomal = 4,
                         window = 49, 
                         derivative = 0,
                         type = "wh",
                         lambda = 10500,
                         d = 2
  )

  # smooth
  data_3 = smooth_intens(data_2,
                         polynomal = 4,
                         window = 49, 
                         derivative = 0,
                         type = "sg"
  )
  
  processed_data = as.data.frame(data_3)
  colnames(processed_data) = c("wavenumber", "intensity") # Ensure correct column names
  processed_data$File = file_name
  
  return(processed_data)
}


for (file in file_list) {
  processed_data = process_spectra(file)
  all_data = bind_rows(all_data, processed_data)
}

ggplot(all_data, aes(x = wavenumber, y = intensity, color = File)) +
  geom_line() +
  facet_wrap(~ File, scales = "free_y") +
  theme_minimal() + 
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    plot.title = element_text(hjust = 0.5)
  ) +
  labs(title = "Processed Spectral Data",
       x = "Wavenumber",
       y = "Intensity")
