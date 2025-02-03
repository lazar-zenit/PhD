# Import libraries
import json
import pandas as pd


# User input
JSON_PATH = "C:/Users/Lenovo/Documents/Programiranje/PhD/MassSpectrometry/datasets/MoNA/library_coi.json"
OUTPUT_FOLDER = "C:/Users/Lenovo/Documents/Programiranje/PhD/MassSpectrometry/datasets/MoNA"


# Open.json file
parsed_data = []
with open(JSON_PATH, 'r', encoding='utf-8') as file:
    for line in file:
        line = line.strip()
        if line:
            parsed_data.append(json.loads(line))

print("JSON loaded!")

# %%
# Empty lists to hold values of interest
name_all = []
precursor_type_all = []
collision_energy_all = []
precursor_mz_all = []
formula_all = []
ion_mode_all = []
ion_mode_all = []
ms2_mz_all = []
ms2_int_all = []
found = 0
not_found = 0


# Iterate over every line
for entry in parsed_data:

    # Extract parts of dictionary that are of interest
    compound = entry.get("compound")
    metaData = entry.get("metaData")
    spectrum = entry.get("spectrum")

    # Process only MS2 spectra
    if [item for item in metaData if item["value"] == "MS2"]:

        # Compound name
        name = compound[0].get("names")[0].get("name")

        # Wheather spectrum is in silico or not
        computed = compound[0].get("computed")

        # Precursor type
        precursor_type = next(
            (item["value"]
             for item in metaData if item["name"] == "precursor type"),
            "Not available")

        # Collision energy
        collision_energy = next(
            (item["value"]
             for item in metaData if item["name"] == "collision energy"),
            "Not available")

        # m/z value of precursor ion
        precursor_mz = next(
            (item["value"]
             for item in metaData if item["name"] == "precursor m/z"),
            "Not available")

        # Molecular formula
        formula = next(
            (item["value"] for item in compound[0].get(
                "metaData") if item["name"] == "molecular formula"),
            "Not available")

        # Mode of ionization
        ion_mode = next(
            (item["value"]
             for item in metaData if item["name"] == "ionization mode"),
            "Not available")

        # Take and process mass spectrum
        pairs = spectrum.split()
        ms2_mz_list = []
        ms2_int_list = []

        for pair in pairs:
            mz, intens = pair. split(":")
            ms2_mz_list.append(mz)
            ms2_int_list.append(intens)

        ms2_mz = ';'.join(ms2_mz_list)
        ms2_int = ';'.join(ms2_int_list)

        # Append extracted values to lists
        name_all.append(name)
        precursor_type_all.append(precursor_type)
        collision_energy_all.append(collision_energy)
        precursor_mz_all.append(precursor_mz)
        formula_all.append(formula)
        ion_mode_all.append(ion_mode)
        ms2_mz_all.append(ms2_mz)
        ms2_int_all.append(ms2_int)

        # Found MS2 spectra counter
        found += 1
        print("Data added: ", found)

    # If spectrum is not MS2, count as well
    else:
        not_found += 1
        print("Skipping entry: No MS2 found in metaData - ", not_found)


# Add lists to dataframe
db = pd.DataFrame()
db['Name'] = name_all
db['Precursor_type'] = precursor_type_all
db['Collision_energy'] = collision_energy_all
db['Precursor_mz'] = precursor_mz_all
db['Formula'] = formula_all
db['Ion_mode'] = ion_mode_all
db['MS2mz'] = ms2_mz_all
db['MS2int'] = ms2_int_all

# Print number of MS2 and not MS2 (MS1) spectra
print("\nNumber of MS2 spectra: ", found)
print("Number of MS1 spectra: ", not_found)

# Save dataframe to .csv
db.to_csv(f"{OUTPUT_FOLDER}/output_library.csv", index=False)


'''
# Code for testing without iteration


random_num = random.randint(0, 7942)
all_values = parsed_data[random_num]


compound = all_values.get("compound")
metaData = all_values.get("metaData")
spectrum = all_values.get("spectrum")

if [item for item in metaData if item["value"] == "MS2"]:
    name = compound[0].get("names")[0].get("name")
    print("\nName of the compound: ", name)

    computed = compound[0].get("computed")
    print("In silico spectrum? ", computed)

    precursor_type = next(
        (item["value"] for item in metaData if item["name"] == "precursor type"))
    print("Precursor type: ", precursor_type)

    collision_energy = next(
        (item["value"] for item in metaData if item["name"] == "collision energy"))
    print("Collision energy: ", collision_energy, "eV")

    precursor_mz = next(
        (item["value"] for item in metaData if item["name"] == "precursor m/z"))
    print("Precursor m/z: ", precursor_mz)

    formula = next(
        (item["value"] for item in compound[0].get("metaData") if item["name"] == "molecular formula"))
    print("Molecular formula: ", formula)

    ion_mode = next(
        (item["value"] for item in metaData if item["name"] == "ionization mode"))
    print("Ionization mode: : ", ion_mode)

    pairs = spectrum.split()
    ms2_mz_list = []
    ms2_int_list = []

    for pair in pairs:
        mz, intens = pair. split(":")
        ms2_mz_list.append(mz)
        ms2_int_list.append(intens)

    ms2_mz = ';'.join(ms2_mz_list)
    ms2_int = ';'.join(ms2_int_list)

    print("MS2 m/z values: ", ms2_mz)
    print("MS2 intensity values: ", ms2_int)


else:
    print("Skipping entry: No MS2 found in metaData.")

'''
