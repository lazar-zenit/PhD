# Load libraries
library(ggplot2)
library(MASS)
library(prospectr)
library(ggord)
library(caret)

# User input -------------------------------------------------------------------

# Import pre-prepared datasets
lda.df <- read.csv(file.choose())

# Enter sizes of train and test datasets (random subset)
percent.train <- 0.8
percent.test <- 0.2

# Dataset preparation ----------------------------------------------------------

# Scale the dataset
lda.df[, 2] <- scale(lda.df[, 2])

lda.df[ , apply(lda.df, 2, function(x) !any(is.na(x)))]
lda.df <- lda.df[-2]

View(lda.df)

# Check mean and standard deviation
scaled.mean <- apply(lda.df[, 2], 2, mean) # should be realy small value
scaled.sd <- apply(lda.df[, 2], 2, sd)   # should be 1

# Print meand and standard deviation
print(paste("Mean (should be really small value): ", scaled.mean, "\n"))
print(paste("Standard deviation (should be 1): ", scaled.sd, "\n"))

# Dataset division (random) ----------------------------------------------------

# Make random list of rows
random.rows <- as.list(sample(1:nrow(lda.df)))

# Determine sizes of train and test sets
train.size <- floor(percent.train * nrow(lda.df))
test.size <- nrow(lda.df) - train.size

# Make a list of rows for each set
train.list <- as.list(random.rows[1:train.size])
test.list <- as.list(random.rows[(train.size + 1):nrow(lda.df)])

# Subset original dataframe to obtain train and test dataframes
train <- lda.df[unlist(train.list), ]  
test <- lda.df[unlist(test.list), ]


# Linear Discriminant Analysis -------------------------------------------------

# Fit model
model <- lda(Type~., data=train)

# Model prediction 
prediction <- predict(model, test)

# Training error ---------------------------------------------------------------

# Build table
conf <- table(list(predicted = prediction$class, observed = test$Type))

# Perform confusion matrix test
train.error <- confusionMatrix(conf)
train.error$overall['Accuracy']
train.error$overall['AccuracyPValue']
train.error.summary <- paste("Training error of the model \n",
                             "Accuracy: ", round(train.error$overall['Accuracy'], 2)*100, "% \n",
                             "p-value: ", train.error$overall['AccuracyPValue'])

# Testing error ----------------------------------------------------------------

# Rerun model with leave one out cross validation
model2 <- model <- lda(Type~., data=train, CV=T)

# Perform confusion matrix test
conf2 <- table(list(model2$class, observed=train$Type))
test.error <- confusionMatrix(conf2)
test.error$overall['Accuracy']
test.error$overall['AccuracyPValue']
test.error.summary <- paste("Testing error of the model \n",
                             "Accuracy: ", round(test.error$overall['Accuracy'], 2)*100, "% \n",
                            "p-value: ", test.error$overall['AccuracyPValue'])


# Plot the results -------------------------------------------------------------

# Make a dataframe
lda_data <- data.frame(prediction$x, Type = test$Type)

# Plot 1D plot - two classes will give just LD1
ggplot(lda_data, aes(x = LD1, fill = Type)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("Control" = "#003f5c", "Treatment" = "#ff6361")) +
  annotate("text", x = 0, y = 0.2, label = paste(train.error.summary, "\n", "\n", test.error.summary), size = 3, color = "black") +
  labs(title = "LDA 1D Plot", x = "LD 1") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5)) 
