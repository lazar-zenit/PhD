#############
# LIBRARIES #
#############

import pandas as pd
import tkinter as tk
from tkinter import filedialog
import os
import time
import glob
import numpy as np

#############
# FUNCTIONS #
#############
# choose folder function
def choose_input_folder():
    root = tk.Tk()
    root.withdraw()  # Hide the root window
    folder_path = filedialog.askdirectory(title = "Select folder of .mzXML files")  # Open the dialog to choose a directory
    return folder_path


def choose_output_folder():
    root = tk.Tk()
    root.withdraw()  # Hide the root window
    out_folder_path = filedialog.askdirectory(title = "Select output folder")  # Open the dialog to choose a directory
    return out_folder_path


# matching function
def align(dataframes, rt_tolerance, mz_tolerance):
    
    print("Filtering rows with prediction < 0.5...") 
    dataframes = [df[df['prediction'] >= 0.5] for df in dataframes]
    print("Filtering completed.\n")

    
    matched_df = pd.DataFrame()
    
    # iterate through pairs
    for i, df1 in enumerate(dataframes):
        print(f"Processing File {i + 1}...")
        for j, df2 in enumerate(dataframes):
            if i<= j:
                continue
        
        print(f"  Matching File {i + 1} with File {j + 1}...")    
        
        for _,row1 in df1.iterrows():
            matches =df2 [
                (np.abs(df2['rt'] - row1['rt']) <= rt_tolerance) &
                (np.abs(df2['precursor_MZ'] - row1['precursor_MZ']) <= mz_tolerance)
                ]
            if not matches.empty:
                for _, row2 in matches.iterrows():
                    matched_row = pd.concat([row1, row2], axis = 0)
                    matched_df = pd.concat([matched_df, 
                                            matched_row.to_frame().T], 
                                           ignore_index = True)
                    
    print("Matching completed.")                
    return matched_df
###############################################################################

# select folder
selected_folder = choose_input_folder()
print(f"Selected input folder: {selected_folder}")

out_folder_path = choose_output_folder()
print(f"Selected output folder: {out_folder_path} \n")
#start the timer
start=time.time()

# get file paths
file_paths = glob.glob(f"{selected_folder}/*.csv")
file_names = [os.path.basename(path) for path in file_paths]
print(f"Loaded files: {file_names}")

dataframes = [pd.read_csv(file) for file in file_paths]

# input tolerances
rt_tolerance = 0.15
mz_tolerance = 0.001

###############################################################################
# run function
matched_rows = align(dataframes, rt_tolerance, mz_tolerance)
print(matched_rows)

#stop the timer and calculate time elapsed


output_path = os.path.join(out_folder_path, "matched_results.csv")
matched_rows.to_csv(output_path, index=False)
print(f"Matched results saved to {output_path} \n")

end=time.time()
print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))