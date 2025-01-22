import pandas as pd
import numpy as np
import tkinter as tk
from tkinter import  filedialog
import matplotlib.pyplot as plt
import seaborn as sns

# define file-choosing function
def choose_file():
    
    root = tk.Tk()
    root.withdraw()
    file_path = filedialog.askopenfilename(filetypes = [(".csv files", "*.csv")])
    
    return file_path

# define Mulplicative Scatter Correction function
def MSC(input_data, reference = None):
    
    # Iterate over rows of data
    for i in range (input_data.shape[0]):
        
        # Subtract mean spectra from original
        input_data[i, :] -= input_data[i, :].mean()
        
        # Get the reference spectrum or calculate mean spectra
        if reference is None:
            ref = np.mean(input_data, axis = 0)
        else:
            ref = reference 
            
        # New empty array for results
        data_msc = np.zeros_like(input_data)
        
        for i in range(input_data.shape[0]):
            
            # Run first degree regression
            fit = np.polyfit(ref, input_data[i, :], 1, full = True)
             
            # Apply correction
            data_msc[i, :] = (input_data[i, :] - fit[0][1]) / fit[0][0]
             
        return (data_msc, ref)

"""
# Find .csv file
file_path = choose_file()
if file_path:
    print(f"Selected file: {file_path}")
else:
    print("No file selected")
"""

file_path = "C:/Users/Lenovo/Documents/PhD/Stefan/Arsen novo okt/Quasar preprocessing/preprocessed_0h_numeric.csv"
# Open file path as pandas dataframe           
df = pd.read_csv(file_path)

# Convert dataframe to numpy array
input_data = df.to_numpy()
# Perform Multiplicative Scatter Correction
data_msc = MSC(input_data)

Xmsc = MSC(input_data)[0]

msc_process_df = pd.DataFrame(Xmsc, columns=df.columns)

print(msc_process_df)


# Plot both spectra
fig, axes = plt.subplots(1, 2, figsize=(12, 6), sharey=True)

# Plot original spectra
for i, row in df.iterrows():
    sns.lineplot(x=df.columns, y=row.values, ax=axes[0])
axes[0].set_title("Raw")
axes[0].set_xlabel("Wavenumber")
axes[0].set_ylabel("Absorbance")

# Plot MSC spectra  
for i, row in msc_process_df.iterrows():
    sns.lineplot(x=msc_process_df.columns, y=row.values, ax=axes[1])
axes[1].set_title("MSC")
axes[1].set_xlabel("Wavenumber")
axes[1].set_ylabel("Absorbance")

plt.tight_layout()
plt.show()

fig.savefig("output_plot.png")



  
