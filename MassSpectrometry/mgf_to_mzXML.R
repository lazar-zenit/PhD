# install BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# install MSnbase through BiocManager
BiocManager::install("MSnbase")

# load library
library(MSnbase)

# load .mgf
mgf.path <- "C:/Users/Lenovo/Documents/PhD/Godjevac/TT/abf/BU/alligned export/Mgf_2024_12_05_13_33_04_AlignmentResult_2024_12_05_13_20_28.mgf"

spectrum <- readMgfData(mgf.path)

mzxml.path <- "C:/Users/Lenovo/Documents/PhD/Godjevac/TT/abf/BU/alligned export/BU.mzXML"
writeMSData(spectrum, file = mzxml.path, format = "mzXML")

class(spectrum)
