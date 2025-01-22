# import libraries
library(ggplot2)
library(prospectr)
library(pls)
library(factoextra)
library(FactoMineR)
library(parallel)

# User input -------------------------------------------------------------------

# Import data
df <- read.csv(file.choose(), check.names = FALSE)

# Inspect dataframe
View(df)

# Drop irelevant columns
plsr.df <- df[, !names(df) %in% c("Type", "Leaf", "Plant", "Tag")]

# Inspect dataframe
View(plsr.df)

# Enter ratio of train (calibration) individuals
percent.train <- 0.75

#            You can run the following code together to the end                #  

# Kennard-Stone (Euclidian) ----------------------------------------------------

# Start timer
start_time <- Sys.time()

# Calculate number of train individuals
train.size <- floor(percent.train * nrow(plsr.df))

# Run Kennard-Stone function
kennard.euclid <- kenStone(plsr.df, train.size, metric = 'euclid')

# Subset original dataframe
train.kennard.euclid <- plsr.df[kennard.euclid$model, ]
test.kennard.euclid <- plsr.df[kennard.euclid$test, ]

# Plot parameters
par(mfrow = c(2, 3))
par(mar = c(5, 5, 4, 2) + 0.1)

# Visual representation of subsetting ------------------------------------------

# Take only numerical values
df.active <- plsr.df[, 2:ncol(plsr.df)]

# Perform PCA
pca.results <- PCA(df.active, graph = FALSE)

# Assign colors to points in the model and test set
model.indices <- kennard.euclid$model
test.indices <- kennard.euclid$test

# Assign red to points in the test set
point_colors <- rep("red", nrow(pca.results$ind$coord))

# Assign blue to points in the model set
point_colors[model.indices] <- "blue"

# Plot
plot(
  pca.results$ind$coord[, 1],
  # PC1
  pca.results$ind$coord[, 2],
  # PC2
  pch = 19,
  # Filled circle points
  col = point_colors,
  # Assign colors
  xlab = "PC1",
  ylab = "PC2",
  main = "Model vs. Test set"
)

# Add legend for clarity
legend(
  "topright",
  legend = c("Model Set", "Test Set"),
  col = c("blue", "red"),
  pch = 19
)


# PLSR -------------------------------------------------------------------------

# Run on x cores parallel
num_cores <- 6
cluster = makeCluster(num_cores, type = "PSOCK")
pls.options(parallel = cluster)

# Run the model
model <- plsr(Time ~ ., data = train.kennard.euclid, validation = 'LOO')

# Calculate optimal number of components
num.comp <- selectNcomp(
  model,
  method = c("randomization"),
  nperm = 999,
  alpha = 0.01,
  ncomp = model$ncomp,
  plot = TRUE,
  main = "RMSEP vs. number \n of components"
)

# Make model prediction with advised number of components
model.prediction <- predict(model, test.kennard.euclid, ncomp = num.comp)

# Make linear model of predicted vs. actual
prediction.lm = lm(model.prediction ~ test.kennard.euclid$Time)
model_summary <- summary(prediction.lm)


# Info about linear model
intercept <- coef(model_summary)[1, 1]
slope <- coef(model_summary)[2, 1]
r_squared <- model_summary$r.squared
p_value <- model_summary$coefficients[2, 4]
residuals <- residuals(prediction.lm)
mean_residual <- mean(residuals)
min_residual <- min(residuals)
max_residual <- max(residuals)
sd_residual <- sd(residuals)
median_residual <- median(residuals)

# Create the text to add to the plot
summary_text <- paste(
  "Intercept:",
  round(intercept, 2),
  "\nSlope:",
  round(slope, 2),
  "\nR-squared:",
  round(r_squared, 2),
  "\nP-value:",
  format(p_value, scientific = TRUE),
  "\nMean Residual:",
  round(mean_residual, 2),
  "\nSD Residual:",
  round(sd_residual, 2),
  "\nMedian residual:",
  round(median_residual, 2),
  "\nMax Residual:",
  round(max_residual, 2),
  "\nMin Residual:",
  round(min_residual, 2),
  "\nNumber of components:",
  num.comp
)

# Plot pred vs actual and add summary text
plot(
  test.kennard.euclid$Time,
  model.prediction,
  xlab = "Actual Values",
  ylab = "Predicted Values",
  main = "Predicted vs. Actual",
  xlim = c(0, 80),
  ylim = c(0, 80),
  col = "steelblue",
  pch = 16
) +
  abline(0, 1, col = "red") +
  abline(prediction.lm, col = "blue")

text(
  x = 0,
  y = 50,
  labels = summary_text,
  pos = 4,
  cex = 1,
  col = "black"
)

# Plots of regression coefficients for first 9 components
plot(model,
     plottype = "coef",
     ncomp = 1:3,
     legendpos = "bottomleft")

plot(model,
     plottype = "coef",
     ncomp = 4:6,
     legendpos = "bottomleft")

plot(model,
     plottype = "coef",
     ncomp = 7:9,
     legendpos = "bottom")

# Uncomment if you need .txt file with summary statistic
#writeLines(summary_text, "output.txt")

# Stop parallel cluster
A

# Stop the timer and print time elasped
end_time <- Sys.time()
elapsed_time <- end_time - start_time
print(elapsed_time)

