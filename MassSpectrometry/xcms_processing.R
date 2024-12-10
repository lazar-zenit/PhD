# install libraries if not present
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("xcms")
BiocManager::install("MSnbase", force = TRUE)

# load libraries
library(BiocParallel)
library(xcms)
#library(MSnbase)
library(MsExperiment)
library(dplyr)
library(tcltk)

# select files
mzxml_files <- list.files("~/PhD/Godjevac/TT/mzXML_test", 
                   full.names = TRUE, 
                   recursive = TRUE
                   )

# metadata
# TO BE ADDED


################################################################################
#                         MSEXPERIMENT ROUTE                                   #
################################################################################

###################
# FILES AND PATHS #
###################

# select files
files.folder <- tk_choose.dir(default = "", 
                              caption = "Select location of .mzXML files")
  # "~/PhD/Godjevac/TT/mzXML_test"

# list of file paths
mzxml_files <- list.files(files.folder, 
                          full.names = TRUE, 
                          recursive = TRUE
)

# list of file names
file.names <- list.files(files.folder)

# change names for later output
new.files.names <- paste0("processed_", file.names)


##########
# IMPORT #
##########

# import raw data
#-----------------------------run together-------------------------------------#
start_time <- Sys.time()
ms_exp <- readMsExperiment(spectraFiles = mzxml_files)
end_time <- Sys.time()
elapsed_time <- end_time - start_time
print(elapsed_time)
#------------------------------------------------------------------------------#

# import metadata
# TBA

#check MS object
ms_exp

# sequential list of ALL spectra
spectra(ms_exp)

# number of spectra per file
table(fromFile(ms_exp))

# base peak chromatograms
#---------------------------run together---------------------------------------#
start_time <- Sys.time()
bpis <- chromatogram(ms_exp, aggregationFun = "max")
end_time <- Sys.time()
elapsed_time <- end_time - start_time
print(elapsed_time)
#------------------------------------------------------------------------------#

# plot the chromatogram
plot(bpis)

###################
# CENTWAVE PARAMS #
###################
# enter desired retention times and m/z as seen from ful chromatogram
rtr <- c(as.numeric(7.3*60), as.numeric(8.3*60))
mzr <- c(as.numeric(470), as.numeric(500))

# build chromatogram
chr_raw <- chromatogram(ms_exp, mz = mzr, rt = rtr)
plot(chr_raw)

# determine ppms 
ms_exp %>%
  filterRt(rt = rtr) %>%
  filterMz(mz = mzr) %>%
  plot(type = "XIC")


# find peaks using said parameters
#-----------------------------------run together-------------------------------#
start_time <- Sys.time()
xchr <- findChromPeaks(ms_exp, param = CentWaveParam(peakwidth = c(5, 20),
                                                     ppm = 1)) 
end_time <- Sys.time()
elapsed_time <- end_time - start_time
print(elapsed_time)
#------------------------------------------------------------------------------#
# access found peaks
chromPeaks(xchr)
chromPeakData(xchr)

processed_ms <- adjustRtime(xchr, param = ObiwarpParam(binSize = 0.6))

exp <- as(adj_rt, "XCMSnExp")
exp

filenames <- c("1", "2", "3", "4", "5", "6", "7")

writeMSData(exp,
            file = filenames,
            outformat = "mzxml")

fill_peaks <- fillChromPeaks(adj_rt, param = ChromPeakAreaParam())

###########
# MSNBASE #
###########

# import traw data into XCMS using MSnbase
raw_data <- readMSData(mzxml_files, 
                       pdata = NULL, # metadata table to add
                       mode = "onDisk")


#################################
# PROCESSING USING XCMS AS SUCH #
#################################
xset <- xcmsSet(mzxml_files)           # peak picking
xsg <- group(xset)                     # peak alignment
xsg <- retcor(xsg)                     # retention time correction
xsg <- group(xsg)                      # re-align after correction
xsg <- fillPeaks(xsg)                  # fill missing peaks

start_time <- Sys.time()

xsg <- fillPeaks(xsg) 

end_time <- Sys.time()
elapsed_time <- end_time - start_time
print(elapsed_time)

#check the class of the object
class(xsg)

# save mzXML files - KURAC ĆE RADI
xcmsn_exp <- as(xsg, "XCMSnExp")

writeMSData(xsg,
            file = mzxml_files,
            outformat = "mzxml")

# save data to .csv fil - NEEDS WORK
dat <- groupval(xsg, "medret", "into")
dat <- rbind(group = as.character(dat))
write.csv(dat, file = "peak_table_test.csv")


