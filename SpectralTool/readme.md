# What is Rainbow Spectrum
Rainbow spectrum is a method of visualy representing features of a spectrum that
contribute the most to the Principal Component Analysis (PCA). In essessence it serves as
at-glance-method of visualy inspecting differences in multiple spectra.

# How does that work
If multiple spectra are produced, each one coming from a different experiment, we apply
PCA to see if there are any trends in the data, as well as to reduce dimensionality of our thata.

What that means is we will identify regions that contribute the most to overall model
letting us pick them for further analysis.

All this script does is doing PCA on an ATR-FTIR spectra that was previously preprocessed,
calculates loadings for each variable and displays it as a gradient on a mean spectra.
Sign of a loading is no use to us (correlation being imaginary model magic anyways), we just
want to identfy the regions of interest.

# What are steps in achieving this?
1. Acquire the spectral data
2. Batch process them using Open Specy R-library or web app
3. Perform the PCA
4. Save the loadings from PCA and apply them to mean spectra