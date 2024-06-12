import pandas as pd
import os
import time
import glob

# directory path
raw_path = r"G:\My Drive\PhD\Doktorat\FTIR analysis\Spektri master\Dekonvolucija\reports"
os_path = raw_path.replace('\\', '/')
directory = os.path.abspath(os_path)

start = time.time()

# glob makes list of all .txt files within a folder
file_paths = glob.glob(os.path.join(directory, '*.txt'))

# create empty list
data = []

# loop
for file_path in file_paths:
    with open(file_path, 'r') as file:
        content = file.read()
        
        for line in content.split('\n'):
            if line.strip(): 
                parts = line.split('=')
                if len(parts) == 2:
                    key = parts[0].strip()
                    value = parts[1].strip()
                    mean_value, uncertainty = value.split('±')
                    mean_value = mean_value.strip()
                    uncertainty = uncertainty.strip()
                    
                    data.append({
                        'File': os.path.basename(file_path),
                        'Key': key,
                        'Mean Value': mean_value,
                        'Uncertainty': uncertainty
                        })

df = pd.DataFrame(data)
df.to_csv('output.csv', index=False)

end = time.time()
print('Time elapsed (minutes):'
	  , round((end-start)/60, 2), 
	  '\nTime elapsed (seconds):', 
	  round(end-start, 2))