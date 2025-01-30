# Import libraries
import json
import time
import ijson
from pathlib import Path

# Function for extracting InChI from big files (tens of GB)


def ijson_extract_inchi(file_path):

    inchi_list = []

    with open(file_path, 'rb') as file:
        parser = ijson.parse(file)

        for prefix, event, value in parser:
            if prefix.endswith('.compound.item.inchi') and event == 'string' and value.strip():
                inchi_list.append(value)

    with open(output_file_name, 'w') as file:
        for inchi in inchi_list:
            file.write(inchi + '\n')

# Function for extracting InChI from smaller files (u to couple of GB)


def extract_inchi(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)

    inchi_list = []

    for item in data:
        if 'compound' in item and isinstance(item['compound'], list) and len(item['compound']) > 0:
            # Get the first dict from the compound list
            compound = item['compound'][0]
            if 'inchi' in compound:
                inchi_list.append(compound['inchi'])

    with open('inchi_list.txt', 'w') as file:
        for inchi in inchi_list:
            file.write(inchi + '\n')
            print(inchi, " found and saved")


# Input file path
file_path = "D:/PhD backup/MoNA/Full library/MoNA JSON/MoNA-export-All_Spectra-json/MoNA-export-All_Spectra.json"
output_path = Path(
    "D:/PhD backup/MoNA/Full library/MoNA JSON/MoNA-export-All_Spectra-json/Split files")

output_file_name = output_path / "inchi_list.txt"

# Start timer
start = time.time()

# Perform InCHI extraction on big file
ijson_extract_inchi(file_path)


# stop the timer and calculate time elapsed
end = time.time()
print('\nTime elapsed (minutes):', round((end-start)/60, 2),
      '\nTime elapsed (seconds):',
      round(end-start, 2))

# %%
output_file_name = output_path / "inchi_list.txt"
# %%
# Cleaning section - output files contain not just InChI formula, but InChIKey and NA values
file_for_cleaning = output_file_name
cleaned_output_file = output_path / "inchi_list_clean.txt"

with open(file_for_cleaning, "r") as infile, open(cleaned_output_file, "w") as outfile:
    for line in infile:
        # Check if the line starts with "InChI="
        if line.startswith("InChI="):
            outfile.write(line)

print("Filtered lines saved to", cleaned_output_file)
