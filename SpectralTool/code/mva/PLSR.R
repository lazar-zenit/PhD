# import libraries
library(ggplot2)
library(prospectr)
library(pls)


# import data
plsr.df <- read.csv(file.choose())

################################################################################
#                         Dataset division                                     #
################################################################################

                          ###################
                          # Random division #
                          ###################

# enter sizes of train and test datasets
percent.train <- 0.8
percent.test <- 0.2

#----------------------------- run together -----------------------------------#

# make random list of rows
random.rows <- as.list(sample(1:nrow(plsr.df)))

# determine sizes of train and test sets
train.size <- floor(percent.train * nrow(plsr.df))
test.size <- nrow(plsr.df) - train.size

# make a list of rows for each set
train.list <- as.list(random.rows[1:train.size])
test.list <- as.list(random.rows[(train.size + 1):nrow(plsr.df)])

# subset original dataframe to obtain train and test dataframes
train.random <- plsr.df[unlist(train.list), ]  
test.random <- plsr.df[unlist(test.list), ] 

#------------------------------------------------------------------------------#

                    ############################
                    # Kennard-Stone (Euclidian)#
                    ############################

# enter number of train (calibration) individuals
k <- 380

#----------------------------- run together -----------------------------------#

# run Kennard-Stone function
kennard.euclid <- kenStone(plsr.df, k, metric = 'euclid')

# subset original dataframe
train.kennard.euclid <- plsr.df[kennard.euclid$model, ]
test.kennard.euclid <- plsr.df[kennard.euclid$test, ]

#------------------------------------------------------------------------------#

                    #      WORK IN PROGRESS      #
                    #      WORK IN PROGRESS      #
                    #      WORK IN PROGRESS      #
                    #      WORK IN PROGRESS      #
                    #      WORK IN PROGRESS      #

                    ##############################
                    # Kennard-Stone (Mahalanobis)#
                    ##############################

# enter number of train (calibration) individuals
k <- 380

#----------------------------- run together -----------------------------------#

# run Kennard-Stone function
kennard.mahal <- kenStone(plsr.df, k, metric = 'mahal')

# subset original dataframe
train.kennard.mahal <- plsr.df[kennard.mahal$model, ]
test.kennard.mahal <- plsr.df[kennard.mahal$test, ]

#------------------------------------------------------------------------------#

################################################################################
#                                PLSR                                          #
################################################################################

# run the model
#------------------------- run together ---------------------------------------#
start_time <- Sys.time()

model <- plsr(Time ~., data = train.kennard.euclid, validation = 'CV')

end_time <- Sys.time()
elapsed_time <- end_time - start_time
print(elapsed_time)
#------------------------------------------------------------------------------#

summary(model)

# validation and component number
par(mfrow =c(1,3))
validationplot(model)
validationplot(model, val.type="MSEP")
validationplot(model, val.type="R2")

model.prediction <- predict(model, test.kennard.euclid, ncomp = 61)

# calculate root square error (fine tunung number of components)
sqrt(mean((model.prediction - test.kennard.euclid$Time)^2))

# make linear model of predicted vs. actual
prediction.lm = lm(model.prediction ~ test.kennard.euclid$Time)
summary(prediction.lm)

# plot pred vs actual
par(mfrow =c(1,1))
plot(test.kennard.euclid$Time, model.prediction, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Control (Euclid)",
     xlim = c(0, 80),
     ylim = c(0, 80),
     col = "black",
     pch = 16) +
  abline(0, 1, col = "red") +  
  abline(prediction.lm, col = "blue")
