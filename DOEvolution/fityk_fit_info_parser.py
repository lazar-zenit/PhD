import pandas as pd
import os
import time
import glob
import re
import csv
#%%
# BATCH PROCESSING FILES TO REMOVE SPACES 
# directory path
raw_path_dir = r"G:\My Drive\PhD\Doktorat\FTIR analysis\Spektri master\Dekonvolucija\reports"
os_path_dir = raw_path_dir.replace('\\', '/')
dir_path = os.path.abspath(os_path_dir)

# glob makes list of all .txt files within a folder
file_paths = glob.glob(os.path.join(dir_path, '*.txt'))

# loop to process each file
for file_path in file_paths:
    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Remove the first line and strip spaces from the remaining lines
    processed_lines = [line.replace(' ', '') for line in lines[1:]]

    # Write the processed lines back to the file
    with open(file_path, 'w') as file:
        file.writelines(processed_lines)

print("All files have been processed.")
#%%%
# TEST FOR PATTERN ON SINGLE FILE - PROBLEM WITH ESCAPE SEQUENCE
# load the pattern

raw_path = r"G:\My Drive\PhD\Doktorat\FTIR analysis\Spektri master\Dekonvolucija\reports\e1.txt"
os_path_file = raw_path_dir.replace('\\', '/')
file_path = os.path.abspath(os_path_file)

pattern = re.compile(r"\\$\_\\d+\=%\_\d+\.(\w+)\=(-?\d+(?:\.\d+)?(?:e-?\d+)?)±(-?\d+(?:\.\d+)?(?:e-?\d+)?)")
    
# match the pattern
with open(file_path, 'r') as file:
    for line in file:
        match = re.match(pattern, line.strip())

        param = match.group(1)
        value = float(match.group(2))
        uncertainty = float(match.group(3))
        
print(param, ' ', value, '±', uncertainty)





'''
def parse_line(line):
    # load the pattern
    pattern = r"\\$\_\\d+\=%\_\d+\.(\w+)\=(-?\d+(?:\.\d+)?(?:e-?\d+)?)±(-?\d+(?:\.\d+)?(?:e-?\d+)?)"
    
    # match the pattern
    match = re.match(pattern, line.strip())
    
    # if match is found, take parameter, value and uncertainty
    # all required terms are in groups (in code as brackets '()')
    # else do nothing
    if match:
        param = match.group(1)
        value = float(match.group(2))
        uncertainty = float(match.group(3))
        return param, value, uncertainty
    
    return None


def process_file(input_file_path, output_file_path):
    results = []
    
    with open(input_file_path, 'r') as input_file:
        for line in input_file:
            parsed_result = parse_line(line)
            if parsed_result:
                results.append(parsed_result)
            
    with open(output_file_path, 'w', newline='') as output_file:
        writer = csv.writer(output_file)
        writer.writerow(['Parameter', 'Value', 'Uncertainty'])
        writer.writerows(results)
    
    print(f"Processed results saved to {output_file_path}")



input_file_path = 'G:/My Drive/PhD/Doktorat/FTIR analysis/Spektri master/Dekonvolucija/reports/e1.txt'
output_file_path = 'G:/My Drive/PhD/Doktorat/FTIR analysis/Spektri master/Dekonvolucija/reports/e1_parsed.csv'

process_file(input_file_path, output_file_path)
'''
'''
#read file
with open(file_path, 'r') as file:
    for line in file:
        result = parse_line(line)
        
        if result:
            param, value, uncertainty = result
            if param not in data:
                data[param] = []
            
            data[param].append(value, uncertainty)
            
            
# print the parsed data
print(data)
'''

