import pandas as pd
import os
import time

#file path from windows copy path. MIND THE 'r'.
raw_path=r"G:\My Drive\PhD\Doktorat\FTIR analysis\Spektri master\Dekonvolucija\fityk_input.csv"
os_path=raw_path.replace('\\', '/')
file_path = os.path.abspath(os_path)

#start the timer
start = time.time()

# open the .csv file
df = pd.read_csv(file_path)

# define column variables
x_column = df.columns[0]
y_columns = df.columns[1:]

#separating .csv file into smaller files
for y_column in y_columns:
    # new dataframe containing x and y
    new_df = df[[x_column, y_column]]
    
    # define output
    output = f'{y_column}.csv'
    
    # export output
    new_df.to_csv(output, index = False)
    
    print('File separated')
   

#stop the timer and calculate time elapsed
end = time.time()
print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))