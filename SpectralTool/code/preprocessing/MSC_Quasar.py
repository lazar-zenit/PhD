import numpy as np
from Orange.data import Table

def MSC(input_data):
    data_msc = np.zeros_like(input_data)
    ref = np.mean(input_data, axis=0)
    
    for i in range(input_data.shape[0]):
        # Run first-degree regression
        fit = np.polyfit(ref, input_data[i, :], 1, full=True)
        # Apply correction
        data_msc[i, :] = (input_data[i, :] - fit[0][1]) / fit[0][0]
    
    return data_msc

if 'in_data' in globals():
    # Convert Orange Table to numpy array
    input_data = in_data.X  # Only numeric data
    
    # Perform MSC
    data_msc = MSC(input_data)
    
    # Create a new Orange Table with the transformed data
    output_data = in_data.copy()
    output_data.X = data_msc

    # Assign the output table to the variable 'output', which Orange uses to pass results
    out_data = output_data
