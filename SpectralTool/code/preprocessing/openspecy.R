# setup working directory
setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/viminacijum_out")

# load the libraries
library(OpenSpecy)

###############
# IMPORT FILE #
###############
data = read_text("PedjaB01_processed.csv")

# plot the raw data for inspection
plot(data)

######################
# PROCESSING SPECTRA #
######################

# baseline correction
data_1 = subtr_baseline(data,
               type = "polynomial",
               degree = 8,
               raw = TRUE,
               make_rel = TRUE
               ) 

plot(data_1)

# smooth
data_2 = smooth_intens(data_1,
                       polynomal = 4,
                       window = 49, 
                       derivative = 0,
                       type = "wh",
                       lambda = 10500,
                       d = 2
                       )
plot(data_2)


# smooth
data_3 = smooth_intens(data_2,
                       polynomal = 4,
                       window = 49, 
                       derivative = 0,
                       type = "sg"
                       )
plot(data_3)

