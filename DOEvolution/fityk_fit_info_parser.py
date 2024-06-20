import pandas as pd
import os
import time
import glob
import re
import pandas as pd

#start the timer
start=time.time() 

#%%
# BATCH PROCESSING FILES TO REMOVE SPACES - WORKS
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


#%%
# TEST FOR PATTERN ON SINGLE FILE - WORKS

# load file path
raw_path = r"G:\My Drive\PhD\Doktorat\FTIR analysis\Spektri master\Dekonvolucija\reports\e1.txt"
os_path_file = raw_path.replace('\\', '/')
file_path = os.path.abspath(os_path_file)

# define function to read file
def read_file(file_path):
    with open(file_path, mode = 'r', encoding = 'utf-8') as file:
        return file.read()

# define pattern    
pattern = re.compile(r"\$_\d+=\%_\d+\.(\w+)=(\d+.\d+)±(\d+.\d+)")

# read the file and check
text = read_file(file_path)
print("Your texts is:\n" + text)

# find and check matches
matches = re.findall(pattern, text)  
print("Matches found:\n", matches)

# add columns, put list into dataframe and check
columns = ['param', 'value', 'error']
df = pd.DataFrame(matches, columns = columns)
print(df)

# now extract file name form path
file_name = os.path.basename(file_path)
print("Your file name is:" + file_name)

# split file name (delete .txt extension)
file_name_ex = file_name.split('.')[0]

# insert back into dataframe and check
df.insert(0, 'spectrum', file_name_ex)
print(df)

#%%
# BATCH PROCESS THE FILES

# define function to read .txt files
def read_file(file_path):
    with open(file_path, mode = 'r', encoding = 'utf-8') as file:
        return file.read()

# load the pattern    
pattern = re.compile(r"\$_\d+=\%_\d+\.(\w+)=(\d+.\d+)±(\d+.\d+)")

# load the folder path
folder_path = r"G:\My Drive\PhD\Doktorat\FTIR analysis\Spektri master\Dekonvolucija\reports"

# empty list to store dataframes
df_list = []


# glob makes list of all .txt files within a folder
file_paths = glob.glob(os.path.join(folder_path, '*.txt'))

# loop to process each file
for file_path in file_paths:
    # make file path
    
    #read file
    text = read_file(file_path)
    #print("Your current text is:\n" + text)
    
    # find matches
    matches = re.findall(pattern, text)
    #print("Current matches found:\n", matches)
    
    # add columns to dataframe
    columns = ['param', 'value', 'error']
    df = pd.DataFrame(matches, columns = columns)
    #print(df)
    
    # now extract file name form path
    file_name = os.path.basename(file_path)
    print("Your file name is:" + file_name)

    # split file name (delete .txt extension)
    file_name_ex = file_name.split('.')[0]

    # insert back into dataframe and check
    df.insert(0, 'spectrum', file_name_ex)
    #print(df)
    
    # Append DataFrame to list
    df_list.append(df)

print("All files have been processed.")      
# Concatenate all DataFrames into a single DataFrame
combined_df = pd.concat(df_list, ignore_index=True)
print("Your combined dataframe is:\n", combined_df)

# save dataframe as .csv
combined_df.to_csv("output.csv")
end=time.time()
print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))
