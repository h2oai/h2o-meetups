# ------------------------------------------------------------------------------
# Step 5: Tuning Models via Early Stopping
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
secom_train <- secom_splits[[1]]  # 882 : 62 ... 7% of 1
secom_test  <- secom_splits[[2]]  # 581 : 42 ... 7% of 1


# ------------------------------------------------------------------------------
# Train H2O models with early stopping
# ------------------------------------------------------------------------------

# GBM with default settings
model_gbm1 <- h2o.gbm(x = features,
                      y = target,
                      training_frame = secom_train,
                      ntrees = 50)  # default = 50

# GBM with early stopping and cross validation
model_gbm2 <- h2o.gbm(x = features,
                      y = target,
                      training_frame = secom_train,
                      model_id = "gbm_early_stop", # define an ID

                      # Settings for Early Stopping w/ Cross Validation
                      nfolds = 5,
                      ntrees = 200,
                      stopping_metric = "AUC",
                      score_tree_interval = 3,
                      stopping_rounds = 20)


# ------------------------------------------------------------------------------
# Evaluate model performance on unseen data
# ------------------------------------------------------------------------------

print(model_gbm1)
print(model_gbm2)

h2o.performance(model_gbm1, newdata = secom_test)
h2o.performance(model_gbm2, newdata = secom_test)

