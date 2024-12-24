# install libraries
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("ropls")

# load libraries
library(ggplot2)
library(ropls)

# load dataset
oplsda.df <- read.csv(file.choose())

# declare class and names
class <- oplsda.df[, 1]
dataMatrix <- oplsda.df[, 2:dim(oplsda.df)[2]]

#check class and data matrix
View(class)
View(dataMatrix)


####################
# Dataset division #
####################

# enter sizes of train and test datasets
percent.train <- 0.8
percent.test <- 0.2

# make random list of rows
random.rows <- as.list(sample(1:nrow(oplsda.df)))

# determine sizes of train set
train.size <- floor(percent.train * nrow(oplsda.df))

# make a list of rows for each set
train.list <- as.list(random.rows[1:train.size])

# make vector from the list
train.vector <- unlist(train.list, use.names = FALSE)

n.perm <- 2*nrow(oplsda.df)


start_time <- Sys.time()

# run opls function with default graphs
data.oplsda <- opls(dataMatrix, 
                    class, 
                    predI = NA, 
                    orthoI = NA,
                    #subset = train.vector, 
                    permI = n.perm
                    )


end_time <- Sys.time()
elapsed_time <- end_time - start_time
elapsed_time

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


