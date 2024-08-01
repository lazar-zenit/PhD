# start the timer
start_time = Sys.time()

# setup working directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/omnic_breakoff_input/csv files")


# select range of your wavenumbers
min_wavenumber = 800
max_wavenumber = 1800

# load the libraries
library(OpenSpecy)
library(ggplot2)
library(dplyr)
library(tidyr)

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

# load spectra
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

# plot spectra to inspect
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
  
  # trim spectrum
  data_filtered = restrict_range(data,
                                 min = min_wavenumber,
                                 max = max_wavenumber
                                 )

  
  # baseline correction
  data_1 = subtr_baseline(data_filtered,
                          type = "polynomial",
                          degree = 1,
                          raw = FALSE,
                          make_rel = FALSE,
  ) 
  

  # smooth - Savinsky-Golay
  data_2 = smooth_intens(data_1,
                         polynomal = 4,
                         window = 43, 
                         derivative = 0,
                         type = "sg",
                         make_rel = TRUE
  )


  processed_data = as.data.frame(data_2)
  colnames(processed_data) = c("wavenumber", "intensity") # Ensure correct column names
  processed_data$File = file_name
  
  return(processed_data)
}


for (file in file_list) {
  processed_data = process_spectra(file)
  all_data = bind_rows(all_data, processed_data)
  
}


# pivot table
data_wide = all_data %>%
  pivot_wider(names_from = File, values_from = intensity)

# save resulting table
write.csv(data_wide, "output_openspecy.csv", row.names=FALSE)

ggplot(all_data, aes(x = wavenumber, y = intensity, color = File)) +
  geom_line() +
  facet_wrap(~ File, scales = "free_y") +
  theme_minimal() + 
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    plot.title = element_text(hjust = 0.5)) +
  labs(title = "Processed Spectral Data",
       x = "Wavenumber",
       y = "Intensity")

# End the timer an        d calculate time elapsed
end_time = Sys.time()
print(end_time - start_time)
