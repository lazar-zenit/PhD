# import libraries
library(dplyr)
library(pls)

# set up working directory

setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/preprocessed spectra")

# import data
s1 = read.csv("DPP1_all.csv")
s2 = read.csv("DPP2_all.csv")
s3 = read.csv("DPP3_all.csv")

# inspect dataframes
View(s1)
View(s2)
View(s3)

########################################
# DIVIDE ON TRAINGING AND TESTING DATA #
########################################

# lists of random columns for training and testing data
train_cols = c("Std_9",  # 1
               "Std_7",  # 2
               "Std_29", # 3
               "Std_12", # 4
               "Std_17", # 5
               "Std_14", # 6
               "Std_19", # 7
               "Std_16", # 8
               "Std_23", # 9
               "Std_22", # 10
               "Std_3",  # 11
               "Std_26", # 12
               "Std_1",  # 13
               "Std_2",  # 14
               "Std_28", # 15
               "Std_27", # 16
               "Std_15", # 17
               "Std_24", # 18
               "Std_10", # 19
               "Std_21", # 20
               "Std_18", # 21
               "Std_5",  # 22
               "Std_6",  # 23
               "Std_30"  # 24
               )

test_cols = c("Std_13", # 25
              "Std_20", # 26
              "Std_8",  # 27
              "Std_11", # 28
              "Std_4",  # 29
              "Std_25"  # 30
              )

# perform selection and save datasets
s1_train = s1 %>% select(all_of(train_cols))
s1_test = s1 %>% select(all_of(test_cols))
View(s1_train)
View(s1_test)
write.csv(s1_train, "DPP1_train.csv", row.names=FALSE)
write.csv(s1_test, "DPP1_test.csv", row.names=FALSE)

s2_train = s2 %>% select(all_of(train_cols))
s2_test = s2 %>% select(all_of(test_cols))
View(s2_train)
View(s2_test)
write.csv(s2_train, "DPP2_train.csv", row.names=FALSE)
write.csv(s2_test, "DPP2_test.csv", row.names=FALSE)

s3_train = s3 %>% select(all_of(train_cols))
s3_test = s3 %>% select(all_of(test_cols))
View(s3_train)
View(s3_test)
write.csv(s3_train, "DPP3_train.csv", row.names=FALSE)
write.csv(s3_test, "DPP3_test.csv", row.names=FALSE)


#!!!!!!!!!!!!IMPORTANT!!!!!!!!!!!!!#
####################################
# ADD IDENPENDANT VARIABLE MANUALY #
####################################


##############################
# BUILD AND TEST PLSR MODELS #
##############################

#------#
# DPP1 #
#------#

# import the data with dependant and independant variables
d1_train = read.csv("DPP1_train.csv")
d1_test = read.csv("DPP1_test.csv")
View(d1_train)
View(d1_test)

# train the model
model1 <- plsr(Yields ~ ., data = d1_train, validation = "CV")
summary(model1)

# validation and component number
par(mfrow =c(1,3))
validationplot(model1)
validationplot(model1, val.type="MSEP")
validationplot(model1, val.type="R2")

# make a predicion to training data
m1_pred <- predict(model1, d1_test, ncomp=8)

sqrt(mean((m1_pred - d1_test$Yields)^2))

# Linear model of Pred. vs. Actual
lm1 = lm(m1_pred ~ d1_test$Yields)
summary(lm1)

# plot pred vs actual
plot(d1_test$Yields, m1_pred, 
    xlab = "Actual Values", 
    ylab = "Predicted Values", 
    main = "DPP1",
    xlim = c(0, 25),
    ylim = c(0, 25),
    col = "black",
    pch = 16
    )
abline(0, 1, col = "red")  # Add a y=x line for reference
abline(lm1, col = "blue")

#------#
# DPP2 #
#------#

# import the data with dependant and independant variables
d2_train = read.csv("DPP2_train.csv")
d2_test = read.csv("DPP2_test.csv")
View(d2_train)
View(d2_test)

# train the model
model2 <- plsr(Yields ~ ., data = d2_train, validation = "CV")
summary(model2)

# validation and component number
par(mfrow =c(1,3))
validationplot(model2)
validationplot(model2, val.type="MSEP")
validationplot(model2, val.type="R2")

# make a predicion to training data

m2_pred <- predict(model2, d2_test, ncomp=7)

sqrt(mean((m2_pred - d2_test$Yields)^2))

# Linear model of Pred. vs. Actual
lm2 = lm(m2_pred ~ d2_test$Yields)
summary(lm2)

# plot pred vs actual
plot(d2_test$Yields, m2_pred, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Actual vs Predicted Values - DPP2",
     xlim = c(0, 25),
     ylim = c(0, 25),
     col = "black",
     pch = 16
     )
abline(0, 1, col = "red")
abline(lm2, col = "blue")

#------#
# DPP3 #
#------#

# import the data with dependant and independant variables
d3_train = read.csv("DPP3_train.csv")
d3_test = read.csv("DPP3_test.csv")
View(d3_train)
View(d3_test)

# train the model
model3 <- plsr(Yields ~ ., data = d3_train, validation = "CV")
summary(model3)

# validation and component number
par(mfrow =c(1,3))
validationplot(model3)
validationplot(model3, val.type="MSEP")
validationplot(model3, val.type="R2")

# make a predicion to training data
m3_pred <- predict(model3, d3_test, ncomp=8)

sqrt(mean((m3_pred - d3_test$Yields)^2))

# Linear model of Pred. vs. Actual
lm3 = lm(m3_pred ~ d3_test$Yields)
summary(lm3)

# plot pred vs actual
plot(d3_test$Yields, m3_pred, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "Actual vs Predicted Values - Opencpecy (Webapp)",
     xlim = c(0, 25),
     ylim = c(0, 25),
     col = "black",
     pch = 16
     )
abline(0, 1, col = "red")
abline(lm3, col = "blue")




# Print all graphs
par(mfrow =c(1,3))

plot(d1_test$Yields, m1_pred, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "DPP1",
     xlim = c(0, 35),
     ylim = c(0, 35),
     col = "black",
     pch = 16
)
abline(0, 1, col = "red")  # Add a y=x line for reference
abline(lm1, col = "blue")

plot(d2_test$Yields, m2_pred, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "DPP2",
     xlim = c(0, 35),
     ylim = c(0, 35),
     col = "black",
     pch = 16
)
abline(0, 1, col = "red")
abline(lm2, col = "blue")

plot(d3_test$Yields, m3_pred, 
     xlab = "Actual Values", 
     ylab = "Predicted Values", 
     main = "DPP3",
     xlim = c(0, 35),
     ylim = c(0, 35),
     col = "black",
     pch = 16
)
abline(0, 1, col = "red")
abline(lm3, col = "blue")

par(mfrow =c(1,3))
validationplot(model1, main = "DPP1")
validationplot(model2, main = "DPP2")
validationplot(model3, main = "DPP3")
