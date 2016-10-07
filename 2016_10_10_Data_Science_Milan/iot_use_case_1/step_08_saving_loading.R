# ------------------------------------------------------------------------------
# Step 8: Saving / Loading Models
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
# Train a H2O Model
# ------------------------------------------------------------------------------

# Train a GBM
model_gbm <- h2o.gbm(x = features,
                      y = target,
                      model_id = "default_gbm",
                      training_frame = secom_train)


# ------------------------------------------------------------------------------
# Saving / Loading H2O Model
# ------------------------------------------------------------------------------

# Save model to disk
h2o.saveModel(model_gbm, path = "/models/")

# Load model from disk
model_from_disk <- h2o.loadModel(path = "./models/default_gbm/")
print(model_from_disk)

