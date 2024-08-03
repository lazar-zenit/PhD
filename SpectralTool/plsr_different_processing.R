# import libraries
library(dplyr)
library(pls)

# set up working directory

setwd("C:/Users/Lenovo/Documents/Programiranje/PhD/SpectralTool/datasets/plsr")

# import data
s1 = read.csv("for_split_omnic.csv")
s2 = read.csv("for_split_spectragryph.csv")
s3 = read.csv("for_split_openspecy_webapp.csv")
s4 = read.csv("for_split_openspecy_r.csv")

# inspect dataframes
View(s1)
View(s2)
View(s3)
View(s4)

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

s4_train = s4 %>% select(all_of(train_cols))
s4_test = s4 %>% select(all_of(test_cols))
View(s4_train)
View(s4_test)
write.csv(s4_train, "DPP4_train.csv", row.names=FALSE)
write.csv(s4_test, "DPP4_test.csv", row.names=FALSE)


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
model1 <- plsr(Yields ~ ., data = d1_train, validation = "LOO")
summary(model1)

# validation and component number
validationplot(model1)
validationplot(model1, val.type="MSEP")
validationplot(model1, val.type="R2")

# make a predicion to training data
m1_pred <- predict(model1, d1_test, ncomp=7)

sqrt(mean((m1_pred - d1_test$Yields)^2))

# plot pred vs actual
plot(d1_test$Yields, m1_pred, 
    xlab = "Actual Values", 
    ylab = "Predicted Values", 
    main = "Actual vs Predicted Values")
abline(0, 1, col = "red")  # Add a y=x line for reference
