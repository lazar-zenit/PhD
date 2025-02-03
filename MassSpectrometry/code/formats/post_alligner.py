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
def align(dataframes, rt_tolerance, mz_tolerance, file_names):
    # Preprocess dataframes: Filter out rows where prediction < 0.5
    print("Filtering rows with prediction < 0.5...")
    dataframes = [df[df['prediction'] >= 0.5] for df in dataframes]
    print("Filtering completed.")

    # Initialize an empty DataFrame to store matched results
    matched_df = pd.DataFrame(columns=['rt', 'precursor_MZ', 'mean_prediction'] + 
                              [f'{file_name}_precursor_intensity' for file_name in file_names])

    # Iterate through rows in all files
    for i, df1 in enumerate(dataframes):
        print(f"Processing File {i + 1}...")  # Log the progress of the first file

        for _, row1 in df1.iterrows():
            matched_row = {
                'rt': row1['rt'],
                'precursor_MZ': row1['precursor_MZ'],
                'mean_prediction': row1['prediction']
            }

            # Initialize a dictionary with 0 for all intensities in case no match is found
            intensity_dict = {f'{file_names[k]}_precursor_intensity': 0 for k in range(len(file_names))}
            
            for j, df2 in enumerate(dataframes):
                if i == j:  # Skip self-matching
                    continue

                # Find matches based on rt and precursor_MZ
                matches = df2[
                    (np.abs(df2['rt'] - row1['rt']) <= rt_tolerance) &
                    (np.abs(df2['precursor_MZ'] - row1['precursor_MZ']) <= mz_tolerance)
                ]
                
                if not matches.empty:
                    # Calculate mean prediction for matched rows
                    mean_prediction = matches['prediction'].mean()
                    matched_row['mean_prediction'] = mean_prediction
                    
                    # Add precursor intensities to the dictionary for this specific file
                    for _, match_row in matches.iterrows():
                        intensity_dict[f'{file_names[j]}_precursor_intensity'] = match_row['precursor_intensity']
            
            # Add the intensity data to the matched row
            matched_row.update(intensity_dict)
            
            # Convert matched row to DataFrame
            matched_row_df = pd.DataFrame([matched_row])

            # Concatenate matched row to the results DataFrame
            matched_df = pd.concat([matched_df, matched_row_df], ignore_index=True)

    print("Matching completed.")

    # Ask for the output folder path
    folder_path = choose_output_folder()

    # Combine the folder path with the filename
    output_path = os.path.join(folder_path, "matched_results.csv")

    # Save the matched results to the selected folder
    matched_df.to_csv(output_path, index=False)
    print(f"Matched results saved to {output_path}")

    return matched_df
###############################################################################

# select folder
selected_folder = choose_input_folder()
print(f"Selected input folder: {selected_folder}")

out_folder_path = choose_output_folder()
print(f"Selected output folder: {out_folder_path} \n")


#start the timer
start=time.time()

output_path = os.path.join(out_folder_path, "matched_results.csv")

# get file paths
file_paths = glob.glob(f"{selected_folder}/*.csv")
file_names = [os.path.basename(f) for f in file_paths]
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
end=time.time()
print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))