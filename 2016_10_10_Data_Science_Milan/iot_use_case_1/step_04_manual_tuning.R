# ------------------------------------------------------------------------------
# Step 4: Tuning Models with Manual Tweaks
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Loading and preparing data (same as previous steps)
# ------------------------------------------------------------------------------

# Start and connect to a local H2O cluster
library(h2o)
h2o.init(nthreads = -1)

# Import data from a local CSV file
secom <- h2o.importFile(path = "./data/secom.csv", destination_frame = "secom")

# Convert Classification to factor
secom$Classification <- as.factor(secom$Classification)

# Define Targets and Features
target <- "Classification"
features <- setdiff(colnames(secom), c("ID", "Classification"))

# Split
secom_splits <- h2o.splitFrame(data = secom, ratios = 0.6, seed = 1234)
secom_train <- secom_splits[[1]]
secom_test  <- secom_splits[[2]]


# ------------------------------------------------------------------------------
# Train H2O models with default / manual settings
# ------------------------------------------------------------------------------

# Check out all parameters
# ?h2o.gbm
# ?h2o.deeplearning
# ?h2o.randomForest

# GBM with default settings
model_gbm1 <- h2o.gbm(x = features, y = target,
                     training_frame = secom_train)

# GBM with manual settings
model_gbm2 <- h2o.gbm(x = features, y = target,
                     training_frame = secom_train,
                     validation_frame = secom_test,
                     model_id = "gbm_tuning", # define an ID
                     ntrees = 40,             # default = 50
                     max_depth = 7,           # default = 5
                     sample_rate = 0.75,      # default = 1
                     col_sample_rate = 0.75,  # default = 1
                     learn_rate = 0.05)       # default = 0.1

# Use R / Flow to look at models
print(summary(model_gbm1))
print(summary(model_gbm2))


# ------------------------------------------------------------------------------
# Evaluate model performance on unseen data
# ------------------------------------------------------------------------------

h2o.performance(model_gbm1, newdata = secom_test)
h2o.performance(model_gbm2, newdata = secom_test)


# ------------------------------------------------------------------------------
# Making predictions
# ------------------------------------------------------------------------------

yhat_test <- h2o.predict(model_gbm2, secom_test)
print(head(yhat_test))
print(summary(yhat_test))

