# Import libraries
import json
import time
import ijson
from pathlib import Path
from decimal import Decimal

# %%
# Define functions


# Function for extracting InChI from big files (tens of GB)
def ijson_extract_inchi(file_path, list_file_name):

    inchi_list = []

    with open(file_path, 'rb') as file:
        parser = ijson.parse(file)
        value_num = 0
        for prefix, event, value in parser:
            if prefix.endswith('.compound.item.inchi') and event == 'string' and value.strip():
                inchi_list.append(value)
                value_num = value_num + 1
                print(value_num, " InChI appended to the list")

    with open(list_file_name, 'w') as file:
        for inchi in inchi_list:
            file.write(inchi + '\n')
            print("Writing ", inchi)


# Function for cleaning non InChI values from list
def list_cleaner(list_file_name, cleaned_file_name):
    with open(list_file_name, "r") as infile, open(cleaned_file_name, "w") as outfile:
        for line in infile:
            # Check if the line starts with "InChI="
            if line.startswith("InChI="):
                outfile.write(line)

    print("\nCleaned InChI saved to", cleaned_file_name)


# Function for selecting compounds of interest based on InChI string
def InChI_selector(cleaned_file_name, ioi_file_name):
    with open(cleaned_file_name, 'r') as infile, open(ioi_file_name, 'w') as outfile:
        ioi_no = 0
        for line in infile:
            if string_of_interest in line:
                outfile.write(line)
                ioi_no += + 1
                print("Found InChI of interest! ", ioi_no)

    print("InChI search done!")


# Function for decimal encoder needed for writing dictionaries to .json
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)  # or str(obj) if you prefer strings
        return super(DecimalEncoder, self).default(obj)


# Function for filtering library
def library_filter(file_path, ioi_file_name, coi_file_name):
    try:

        with open(ioi_file_name, 'r') as filter_file:
            inchi_set = {line.strip() for line in filter_file if line.strip()}

            matchings = []

            print("InChI of interest list opened")

        with open(file_path, 'rb') as file:
            parser = ijson.items(file, 'item')
            entry_num = 0
            print("Opening library...")
            for entry in parser:
                if 'compound' in entry:
                    for compound in entry['compound']:
                        if 'inchi' in compound and compound['inchi'] in inchi_set:
                            matchings.append(entry)
                            entry_num += + 1
                            print("Found library match! ", "(", entry_num, ")")
                            break

        with open(coi_file_name, 'w') as file:
            matched_no = 0

            for matched in matchings:
                file.write(json.dumps(matched, cls=DecimalEncoder) + '\n')
                matched_no += 1
                print("Writing spectra... ", "(", matched_no, ")")

        print("Done!")
        return matchings, inchi_set

    except Exception as e:
        print(f"An error occurred while writing to the file: {e}")
        return matchings


# %%
# Inputs

# File path of library
file_path = "C:/Users/Lenovo/Documents/Programiranje/PhD/MassSpectrometry/datasets/MoNA/MoNA-export-MassBank.json"

# Folder path of outputs
output_path = Path(
    "C:/Users/Lenovo/Documents/Programiranje/PhD/MassSpectrometry/datasets/MoNA")

# Filename for list of all InChI from library
list_file_name = output_path / "inchi_list.txt"

# Filename for cleaned list
cleaned_file_name = output_path / "inchi_list_clean.txt"

# Define string of interest
string_of_interest = "Cl"

# Filename for InChI of interest
ioi_file_name = output_path / "inchi_list_ioi.txt"

# Filename for library of compounds of interest
coi_file_name = output_path / "library_coi.json"


# %%
# Perform functions

# Start timer
start = time.time()

# Perform InCHI extraction on big file
ijson_extract_inchi(file_path, list_file_name)

# Perform cleaning of the list of InChI
list_cleaner(list_file_name, cleaned_file_name)

# Select InChI of interest based on string of interest
InChI_selector(cleaned_file_name, ioi_file_name)

# Filter the original library
matches = library_filter(file_path, ioi_file_name, coi_file_name)

# stop the timer and calculate time elapsed
end = time.time()
print('\nTime elapsed (minutes):', round((end-start)/60, 2),
      '\nTime elapsed (seconds):',
      round(end-start, 2))


# %%
'''
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
'''
