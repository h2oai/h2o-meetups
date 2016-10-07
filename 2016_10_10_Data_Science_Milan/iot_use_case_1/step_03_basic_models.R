# ------------------------------------------------------------------------------
# Step 3: Train and Evaluate Simple Models
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Loading data (same as previous steps)
# ------------------------------------------------------------------------------

# Start and connect to a local H2O cluster
library(h2o)
h2o.init(nthreads = -1)

# Import data from a local CSV file
# Source: https://archive.ics.uci.edu/ml/machine-learning-databases/secom/
secom <- h2o.importFile(path = "./data/secom.csv", destination_frame = "secom")

# Convert Classification to factor
secom$Classification <- as.factor(secom$Classification)


# ------------------------------------------------------------------------------
# Define Targets and Features
# ------------------------------------------------------------------------------

target <- "Classification"
features <- setdiff(colnames(secom), c("ID", "Classification"))

print(target)
print(features)


# ------------------------------------------------------------------------------
# Split data into training / test
# ------------------------------------------------------------------------------

# Split
# i.e. using 60% of data for training and 40% for test
secom_splits <- h2o.splitFrame(data = secom, ratios = 0.6, seed = 1234)
secom_train <- secom_splits[[1]]
secom_test  <- secom_splits[[2]]

# Check
summary(secom_train$Classification) # 882 : 62 ... % of 1 = 0.07029478
summary(secom_test$Classification) # 581 : 42 ... % of 1 = 0.07228916


# ------------------------------------------------------------------------------
# Train H2O models with default value
# ------------------------------------------------------------------------------

# Turn off progress bar (if you want to ...)
# h2o.no_progress()

# GBM
model_gbm <- h2o.gbm(x = features, y = target,
                     training_frame = secom_train)

# Random Forest
model_drf <- h2o.randomForest(x = features, y = target,
                              training_frame = secom_train)

# Deep Neural Network
model_dnn <- h2o.deeplearning(x = features, y = target,
                              training_frame = secom_train)

# Use R / Flow to look at models
print(summary(model_gbm))
print(summary(model_drf))
print(summary(model_dnn))


# ------------------------------------------------------------------------------
# Evaluate model performance on unseen data
# ------------------------------------------------------------------------------

h2o.performance(model_gbm, newdata = secom_test)
h2o.performance(model_drf, newdata = secom_test)
h2o.performance(model_dnn, newdata = secom_test)

