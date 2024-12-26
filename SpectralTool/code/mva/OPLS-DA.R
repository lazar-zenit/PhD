# install libraries
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("ropls")

# load libraries
library(ggplot2)
library(ropls)
library(prospectr)

# select work directory
setwd(choose.dir())

# load dataset
oplsda.df <- read.csv(file.choose())
#View(oplsda.df)

# make numeric dataset for Kennard-Stone
# subset the dataframe
df.numeric <- oplsda.df[, 2:ncol(oplsda.df)]
#View(df.numeric)

# declare class and names
class <- oplsda.df[, 1]
dataMatrix <- oplsda.df[, 2:dim(oplsda.df)[2]]

#check class and data matrix
#View(class)
#View(dataMatrix)


####################################
# Dataset division - Kennard-Stone #
####################################

# enter percetage of dataset to be used for training
t <- 0.8

#----------------------------- run together -----------------------------------#
# determine number 
k <- round((nrow(df.numeric) * t), 0)

# run Kennard-Stone function
kennard.euclid <- kenStone(df.numeric, k, metric = 'euclid')

# subset original dataframe
train.vector <- kennard.euclid$model
#------------------------------------------------------------------------------#
#################
# Run the model #
#################

#------------------------------ run together ----------------------------------#
#start timer
start_time <- Sys.time()

# number of permutation - double the size of sample
n.perm <- 2*nrow(oplsda.df)

# run opls function with default graphs
data.oplsda <- opls(dataMatrix, 
                    class, 
                    predI = NA, 
                    orthoI = NA,
                    #subset = train.vector, 
                    permI = n.perm
                    )

# stop the timer and display time elapsed
end_time <- Sys.time()
elapsed_time <- end_time - start_time
elapsed_time
#------------------------------------------------------------------------------#

####################
# Plot the results #
####################

#plot of x-score
plot(data.oplsda,
     typeVc = "x-score"
)

#plot of x-score
plot(data.oplsda,
     typeVc = "correlation"
)

#plot of x-score
plot(data.oplsda,
     typeVc = "permutation"
)

  #plot of predict vs. actual
plot(data.oplsda,
     typeVc = "predict-train"
)


#plot of outliers
plot(data.oplsda,
     typeVc = "outlier"
     )


