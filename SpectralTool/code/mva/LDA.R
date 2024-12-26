# load libraries
library(ggplot2)
library(MASS)
library(prospectr)
library(ggord)
library(caret)

# Import pre-prepared datasets
lda.df <- read.csv(file.choose())
View(lda.df)

#--------------------------- run together -------------------------------------#
#######################
# Prepare the dataset #
#######################

# scale the dataset
lda.df[, 2] <- scale(lda.df[, 2])

#check mean and standard deviation
apply(lda.df[, 2], 2, mean) # should be realy small value
apply(lda.df[, 2], 2, sd)   # should be 1


####################
# Dataset division #
####################

# enter sizes of train and test datasets
percent.train <- 0.8
percent.test <- 0.2

# make random list of rows
random.rows <- as.list(sample(1:nrow(lda.df)))

# determine sizes of train and test sets
train.size <- floor(percent.train * nrow(lda.df))
test.size <- nrow(lda.df) - train.size

# make a list of rows for each set
train.list <- as.list(random.rows[1:train.size])
test.list <- as.list(random.rows[(train.size + 1):nrow(lda.df)])

# subset original dataframe to obtain train and test dataframes
train <- lda.df[unlist(train.list), ]  
test <- lda.df[unlist(test.list), ]


################################
# Linear Discriminant Analysis #
################################

# fit model
model <- lda(Type~., data=train)

# do a prediction
prediction <- predict(model, test)

# confusion matrix - training error
conf <- table(list(predicted = prediction$class, observed = test$Type))

# do the confusion matrix
train.error <- confusionMatrix(conf)
train.error$overall['Accuracy']
train.error$overall['AccuracyPValue']
train.error.summary <- paste("Training error of the model \n",
                             "Accuracy: ", round(train.error$overall['Accuracy'], 2)*100, "% \n",
                             "p-value: ", train.error$overall['AccuracyPValue'])

# to do the testing error we rerun model with leave one out cross validation
model2 <- model <- lda(Type~., data=train, CV=T)

# confusion matrix - testing error
conf2 <- table(list(model2$class, observed=train$Type))
test.error <- confusionMatrix(conf2)
test.error$overall['Accuracy']
test.error$overall['AccuracyPValue']
test.error.summary <- paste("Testing error of the model \n",
                             "Accuracy: ", round(test.error$overall['Accuracy'], 2)*100, "% \n",
                            "p-value: ", test.error$overall['AccuracyPValue'])

####################
# Plot the results #
####################

# make a dataframe
lda_data <- data.frame(prediction$x, Type = test$Type)

# plot 1D plot - two classes wil give just LD1
ggplot(lda_data, aes(x = LD1, fill = Type)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Control" = "#003f5c", "Treatment" = "#ff6361")) +
  annotate("text", x = 0, y = 0.2, label = paste(train.error.summary, "\n", "\n", test.error.summary), size = 3, color = "black") +
  labs(title = "LDA 1D Plot", x = "LD 1") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) 
