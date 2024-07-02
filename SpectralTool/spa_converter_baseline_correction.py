import os
import spectrochempy as scp
import pandas as pd
import time
import glob

#start the timer
start=time.time()

def spectrochempy_process(files):
    # import spectra
    spectra = scp.read_omnic(files, directory = input_dir)

    # slice the sepctra to desired wavenumbers
    max_wavenumber = 1800.0
    min_wavenumber = 600.0
    spectra = spectra[:, max_wavenumber:min_wavenumber]

    # convert negative values
    spectra -= spectra.min()

    # perform rubberband baseline correction
    blc = scp.Baseline(model="rubberband")
    spectra_baseline = blc.fit(spectra)
    spectra_baseline = blc.transform()

    # plot spectra for insceptcion
    spectra.plot()
    spectra_baseline.plot()
    
    # set i to 0
    i = 0

    # recursevly save files to .csv
    for file in files:
        # Create the new filename
        new_filename = file.replace('.spa', '_processed.csv')
        
        # Save the processed dataset starting at i = 0 to the end of the list
        spectra_baseline[i].write_csv(output_dir + f'/{new_filename}')
        
        # add step
        i = i + 1
    
    return

'''
def process_files_for_openspecy(input_pattern, output_dir):
    
    # find all files with pattern
    spectrochempy_processed_files = glob.glob(input_pattern)
    
    # check the patterns
    if not spectrochempy_processed_files:
        print(f"No files found matching the pattern: {input_pattern}")
        return
    
    # if there are files, count the list and show how many    
    print(f"Found {len(spectrochempy_processed_files)} files to process.")
        
    
    for file_path in spectrochempy_processed_files:
        print(f"Processing file: {file_path}")
        
        
        df = pd.read_csv(file_path, 
                         index_col=False, 
                         names=["wavenumber", "intensity"])
        
        
        # get the base name and make new name
        base_name = os.path.basename(file_path)
        new_name = f"{base_name}-for_spectral_processing.csv"
        
        # save cleaned file
        df.to_csv(os.path.join(output_dir, new_name), index=False)
        print(f"Saved cleaned file to: {os.path.join(output_dir, new_name)}\n") 
'''        

# declare input and output directories
input_dir = "C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/viminacijum"
output_dir = "C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/viminacijum_out"
input_pattern = "C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/viminacijum_out/PedjaB*_processed.csv"
# make a file list
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

spectrochempy_process(files)
#process_files_for_openspecy(input_pattern, output_dir)


# end timer and display time elapsed
end=time.time()
print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))