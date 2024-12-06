# import libraries
from pyteomics import mgf
from psims.mzml import MzMLWriter

mgf_path = "C:/Users/Lenovo/Documents/PhD/Godjevac/TT/abf/BU/alligned export/Mgf_2024_12_05_13_33_04_AlignmentResult_2024_12_05_13_20_28.mgf"

mzxml_path = "C:/Users/Lenovo/Documents/PhD/Godjevac/TT/abf/BU/alligned export/BU.mzXML"

with mgf.read(mgf_path) as spectra:
    
    with MzMLWriter(mzxml_path) as writer:
        for spectrum in spectra:
            writer.writ(spectrum)