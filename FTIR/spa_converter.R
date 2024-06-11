#setup work directory
setwd("G:/My Drive/PhD/Doktorat/FTIR analysis/Spektri master/.SPA SIROVO DEKI")

# load OpenSpecy
library(OpenSpecy)

# read . spa file
spektar = read_spa("Lazar 16.spa")

# plot the OpenSpeccy object
plotly_spec(spektar)

# convert object to dataframe
df = as.data.frame(spektar)
View(df)

# delete first row in dataframe
df=df[- 1, ]
View(df)

