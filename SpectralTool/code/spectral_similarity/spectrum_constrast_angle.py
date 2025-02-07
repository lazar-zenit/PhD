# import libraries
import numpy as np
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
import matplotlib.pyplot as plt


# Function for importing .csv as dictionary of vectors
def import_spectra(FILEPATH):

    # Handle file errors
    try:
        df = pd.read_csv(FILEPATH)
    except FileNotFoundError:
        print("Error! File not found at location: {FILEPATH}")
        return {}
    except pd.errors.ParserError:
        print("Error! File could not be parsed by pandas.")
        return {}
    except Exception as e:
        print(f"Error! - {e}")
        return {}

    # make emtpy dictionary and populate it iterativly
    sample_data = {}
    for index, row in df.iterrows():
        sample_name = row.iloc[0]
        intensities = row.iloc[1:].values.astype(float)
        sample_data[sample_name] = intensities

    return sample_data


def spectral_contrast_angle_matrix(sample_data):
    # Error handling
    if not isinstance(sample_data, dict) or len(sample_data) == 0:
        print("Error! Variable is not dictionary or has lenght of 0.")

    # Convert dictionary to list of vectors
    vector_list = list(sample_data.values())

    # Calculate matrix
    similarity_matrix = cosine_similarity(vector_list)

    # Handle errors if there is no matrix
    if similarity_matrix is not None:
        print("Similarity matrix:")
        print(similarity_matrix)

    else:
        print("Error! There is problem with similarity matrix")

    # Convert to Spectral Contrast Angle
    similarity_matrix = np.clip(similarity_matrix, -1.0, 1.0)
    angle_rad = np.arccos(similarity_matrix)
    angle_deg = np.round((np.degrees(angle_rad)), decimals=2)

    print("\n Spectral Contrast angle (degrees):")
    print(angle_deg)

    return angle_deg


# User input
FILEPATH = "C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/central_points_good_mva_transposed.csv"

# Import spectra
data = import_spectra(FILEPATH)

# Check if data is imported correctly
if data:
    for sample, intensities in data.items():
        print(f"Vector shape: {intensities.shape}")

else:
    print("Data import failed!")

# Calculate spectral contrast angle matrices
angle_deg = spectral_contrast_angle_matrix(data)


# Plot the results - rough
plt.figure(figsize=(8, 6))
plt.imshow(angle_deg, cmap='viridis', origin='upper', extent=[
           0, angle_deg.shape[1], angle_deg.shape[0], 0])
plt.colorbar(label='Angle (degrees)')  # Add a colorbar
plt.title('Spectral Contrast Angle Matrix')
plt.xlabel('Spectrum Index')
plt.ylabel('Spectrum Index')

# For larger matrices, annotations can make the plot cluttered
if angle_deg.shape[0] < 10:  # Adjust condition as needed
    for i in range(angle_deg.shape[0]):
        for j in range(angle_deg.shape[1]):
            # 'w' for white text
            plt.text(j, i, f'{angle_deg[i, j]:.2f}',
                     ha='center', va='center', color='w')

plt.tight_layout()  # Adjust layout to prevent labels from overlapping
plt.savefig("similarity_matrix_heatmap.png", dpi=300)
