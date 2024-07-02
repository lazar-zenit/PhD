import os
import spectrochempy as scp
import pandas as pd
import time
import glob

#start the timer
start=time.time()


input_dir_raw = r"C:\Users\Lenovo\Documents\Programiranje\PhD\SpectralTool\datasets\viminacijum"
output_dir = r"C:\Users\Lenovo\Documents\Programiranje\PhD\SpectralTool\datasets\viminacijum_out"

raw_input_path = input_dir_raw
os_input_path=raw_input_path.replace('\\', '/')
dir_path_input = os.path.abspath(os_input_path)

files = ['PedjaB01.spa',
              'PedjaB02.spa',
              'PedjaB03.spa',
              'PedjaB04.spa',
              'PedjaB05.spa', 
              'pedjaMono01.spa',
              'PedjaMono03.spa',
              'PedjaMono04.spa',
              'PedjaMono05.spa',
              'PedjaMono06.spa',
              'PedjaMono07.spa'
              ]


spectra = scp.read_omnic(files, directory="C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/viminacijum")

max_wavenumber = 1800.0
min_wavenumber = 600.0
spectra = spectra[:, max_wavenumber:min_wavenumber]

spectra -= spectra.min()

blc = scp.Baseline(model="rubberband")
spectra_baseline = blc.fit(spectra)
spectra_baseline = blc.transform()

plot = spectra.plot()
plot2 = spectra_baseline.plot()


spectra_baseline.write_excel("out", "C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/viminacijum_out")


#spectrum = scp.read_spa(file_path, 
                        #origin = 'omnic')

end=time.time()
print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))