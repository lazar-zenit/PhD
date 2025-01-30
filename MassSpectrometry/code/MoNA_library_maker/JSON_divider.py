# Import libraries
import json
import random
import time
from pathlib import Path

# Function for making random subset of desired lenght


def subset_spectra(input_file, output_file, sample_size):

    # Load .json
    with open(input_file, 'r') as infile:
        data = json.load(infile)

    # Ensure readability
    if not isinstance(data, list):
        raise ValueError(
            "There is problem with .json file: type is not a list")

    # Randomly sample data
    sampled_data = random.sample(data, min(sample_size, len(data)))

    # Save subsetted file
    with open(output_file, 'w') as outfile:
        json.dump(sampled_data, outfile)

    # Print message
    print(f"Sampled {len(sampled_data)} spectra and saved to {output_file}")


# Fuction for splitting .json into multiple files
def json_divider(input_file):
    with open(input_file, 'r') as json_file:
        data = json.load(json_file)

    chunk_size = len(data) // file_number

    for i in range(file_number):
        file_name = output_path / f"part_{i}.json"
        with open(file_name, 'w') as outfile:
            outfile.write(json.dumps(data[i*chunk_size:(i+1)*chunk_size]))


# Input function parameters
input_file = "D:/PhD backup/MoNA/Full library/MoNA JSON/MoNA-export-All_Spectra-json/MoNA-export-All_Spectra.json"
# output_file = "C:/Users/Lenovo/Documents/Programiranje/PhD/MassSpectrometry/datasets/output_file.json"
output_path = Path(
    "D:/PhD backup/MoNA/Full library/MoNA JSON/MoNA-export-All_Spectra-json/Split files")
# sample_size = 1000
file_number = 15


# Start timer
start = time.time()

# Perform division
json_divider(input_file)

# stop the timer and calculate time elapsed
end = time.time()
print('\nTime elapsed (minutes):', round((end-start)/60, 2),
      '\nTime elapsed (seconds):',
      round(end-start, 2))
