import numpy as np
import os
from LoadSpectrum import read_spa

raw_path=r"G:\My Drive\PhD\Doktorat\FTIR analysis\Spektri master\.SPA SIROVO DEKI\Lazar 1.spa"
os_path=raw_path.replace('\\', '/')
file_path = os.path.abspath(os_path)




spectra, wavelength, title = read_spa(file_path)

print(wavelength)
