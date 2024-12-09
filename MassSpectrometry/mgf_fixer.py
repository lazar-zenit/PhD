#%%
###############
# BOILERPLATE #
###############

# import libraries
import tkinter as tk
from tkinter import filedialog
import os
import time
import re
from pyteomics import mgf, mzxml

# file_choose() function
def choose_file():
    root = tk.Tk()
    root.withdraw()
    file_path = filedialog.askopenfilename(title = "Select the allignment .mgf File")
    return file_path

# choose output folder function
def choose_output_folder():
    root = tk.Tk()
    root.withdraw()
    folder_path = filedialog.askdirectory(title = "Select Output Folder")
    return folder_path

# open the file
file_path = choose_file()

#check file path
if file_path:
    print(f"Selected file: \n {file_path}")
else:
    print("No file selected")
    
#%%
#################
# OPEN MGF FILE #
#################

try:
    with open(file_path, 'r') as file:
        content = file.read()
        print(content)
        
except FileNotFoundError:
    print("File not found!")

except IOError as e:
    print(f"An I/O error occurred: {e}")

#%%
########################
# CHOOSE OUTPUT FOLDER #
########################
output_folder = choose_output_folder()

if not output_folder:
    print("No folder selected. Exiting.")
    exit()

original_file_name = os.path.basename(file_path)
new_file_name = f"Modified_{original_file_name}"    
output_file = os.path.join(output_folder, new_file_name)

new_new_file_name = new_file_name = f"Pyteomics_mod_{original_file_name}"
new_output_file = os.path.join(output_folder, new_new_file_name)

#%%
#######################
# MODIFY THE CONTENTS #
#######################
start=time.time()

# replace tabs with spaces
modified_content = content.replace('\t', ' ')

# remove Num peaks - most important
modified_content = re.sub(r"Num Peaks:[^\n]*\n", "", modified_content)

# tweak the TITLE line
modified_content = re.sub(r"TITLE=[^|]*\|ID=(\d+).*", 
                          lambda match: f"TITLE=S{match.group(1)}", 
                          modified_content)

# convert minutes into seconds and round to three desimls
def convert_rtinminutes_to_seconds(match):
    rt_minutes = float(match.group(1))  
    rt_seconds = round(rt_minutes * 60, 3) 
    return f"RTINSECONDS={rt_seconds}"

modified_content = re.sub(r"RTINMINUTES=([\d.]+)", convert_rtinminutes_to_seconds, modified_content)

# remove ION=
#modified_content = re.sub(r"ION=[^\n]*\n", "", modified_content)
    
    
# cleaning of empty spectra can be achieved using pyteomics    
with mgf.read(output_file) as reader:
    filtered_spectra = [
        spectrum for spectrum in reader
            if 'm/z array' in spectrum and spectrum['m/z array'].size > 0
            ]

# save .mgf file    
mgf.write(filtered_spectra, new_output_file)

# stop the timer
end = time.time()

# print save file location
print(f"File processed and saved as \n{new_output_file}.\n")

# print total number of spectra
print(print(f"Total number of filtered spectra: {len(filtered_spectra)}\n"))

print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))

