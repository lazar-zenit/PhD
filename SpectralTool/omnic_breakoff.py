# import libraries
import os
import pandas as pd
import time
import glob

#start the timer
start = time.time()

def dataframe_clean(file_path):
    # open the .csv file, ignore first row as header
    df = pd.read_csv(file_path)
    
    # Drop the first row
    df = df.drop(df.index[0])

    # Reset index if necessary
    df = df.reset_index(drop=True)
    
    # add new column names
    df.columns = ['wavenumber', 'intensity']
    return df


def process_files(input_pattern, output_dir):
    
    # find all files with pattern
    files = glob.glob(input_pattern)
    
    # check the patterns
    if not files:
        print(f"No files found matching the pattern: {input_pattern}")
        return
    
    # if there are files, count the list and show how many    
    print(f"Found {len(files)} files to process.")
        
    
    for file_path in files:
        print(f"Processing file: {file_path}")
        
        #clean dataframe
        clean_df = dataframe_clean(file_path)
        
        # get the base name and make new name
        base_name = os.path.basename(file_path)
        new_name = f"{base_name}-for_spectral_processing.csv"
        
        # save cleaned file
        clean_df.to_csv(os.path.join(output_dir, new_name), index=False)
        print(f"Saved cleaned file to: {os.path.join(output_dir, new_name)}\n")


input_pattern = "C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/viminacijum_out/PedjaMono*_processed.csv"
output_dir = "C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/omnic_breakoff_output"

process_files(input_pattern, output_dir)

#stop the timer and calculate time elapsed
end = time.time()
print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))