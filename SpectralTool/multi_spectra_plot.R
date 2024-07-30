# set the working directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/omnic_processed/output")

# load the libraries
library(ggplot2)
library(dplyr)

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

# plot spectra a top of one another
ggplot(all_data, aes(x = wavenumber, y = intensity, color = File)) +
  geom_line() +
  theme_minimal() + 
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    plot.title = element_text(hjust = 0.5)
  ) +
  labs(title = "ATR-FTIR spectra processed with OMNIC",
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

