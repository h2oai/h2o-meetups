# ------------------------------------------------------------------------------
# Step 7: Stacking Models with h2oEnsemble Package
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
# Train multiple H2O models
# ------------------------------------------------------------------------------

# Train a GBM 1
model_gbm1 <- h2o.gbm(x = features,
                     y = target,
                     training_frame = secom_train,
                     nfolds = 5,
                     fold_assignment = "Modulo",
                     keep_cross_validation_predictions = TRUE)

# Train a GBM 2
model_gbm2 <- h2o.gbm(x = features,
                      y = target,
                      training_frame = secom_train,
                      sample_rate = 0.8,
                      nfolds = 5,
                      fold_assignment = "Modulo",
                      keep_cross_validation_predictions = TRUE)

# Train a DRF 1
model_drf1 <- h2o.randomForest(x = features,
                              y = target,
                              training_frame = secom_train,
                              nfolds = 5,
                              fold_assignment = "Modulo",
                              keep_cross_validation_predictions = TRUE)

# Train a DRF 2
model_drf2 <- h2o.randomForest(x = features,
                              y = target,
                              training_frame = secom_train,
                              ntrees = 200,
                              nfolds = 5,
                              fold_assignment = "Modulo",
                              keep_cross_validation_predictions = TRUE)


# ------------------------------------------------------------------------------
# Model stacking
# ------------------------------------------------------------------------------

# Load h2oEnsemble
library(h2oEnsemble)

# Define a list of all models
models <- list(model_gbm1, model_gbm2, model_drf1, model_drf2)

# Define the metalearner
custom_dnn_metalearner <- function(...,
                            hidden = c(200, 200, 200),
                            epochs = 1000,
                            activation = "RectifierWithDropout",
                            input_dropout_ratio = 0.2,
                            l1 = 1e-7,
                            l2 = 1e-7
) {
  h2o.deeplearning.wrapper(...,
                           hidden = hidden,
                           epochs = epochs,
                           activation = activation,
                           input_dropout_ratio = input_dropout_ratio,
                           l1 = l1, l2 = l2
  )
}
metalearner <- "custom_dnn_metalearner"

# Use h2oEnsemble::h2o.stack for model stacking
model_stack <- h2o.stack(models = models,
                         metalearner = metalearner,
                         response_frame = secom_train[, target])

# Evalute ensemble performance on test data
print(h2o.ensemble_performance(model_stack, secom_test))

