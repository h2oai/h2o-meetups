# ------------------------------------------------------------------------------
# Step 9: Stacking (h2oEnsemble)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Loading data and define x & y (same as step 4)
# ------------------------------------------------------------------------------

library(mlbench)
data("BostonHousing2")

# Start H2O
library(h2o)
h2o.init(nthreads = -1)

# Import data from R data frame into H2O data frame
h2o_df_boston <- as.h2o(BostonHousing2)

# Define y (target or response) - Corrected Median House Value in USD 1000's
target <- "cmedv"

# Define x (features or predictors)
features <- setdiff(colnames(h2o_df_boston), c("cmedv", "medv"))


# ------------------------------------------------------------------------------
# Split H2O data frame into training and test
# ------------------------------------------------------------------------------

# 90% for training and 10% for testing
h2o_df_split <- h2o.splitFrame(h2o_df_boston, ratios = 0.9, seed = 123)

# Create two new H2O data frames
h2o_df_train <- h2o_df_split[[1]]
h2o_df_test <- h2o_df_split[[2]]


# ------------------------------------------------------------------------------
# Train two different models (GBM and DRF)
# ------------------------------------------------------------------------------

# Define the number of folds
n_fold <- 5

# Train a GBM
model_gbm <- h2o.gbm(x = features,
                     y = target,
                     training_frame = h2o_df_train,
                     nfolds = n_fold,
                     fold_assignment = "Modulo",
                     keep_cross_validation_predictions = TRUE)

# Train a DRF
model_drf <- h2o.randomForest(x = features,
                              y = target,
                              training_frame = h2o_df_train,
                              nfolds = n_fold,
                              fold_assignment = "Modulo",
                              keep_cross_validation_predictions = TRUE)


# ------------------------------------------------------------------------------
# Model stacking
# ------------------------------------------------------------------------------

# Load h2oEnsemble
library(h2oEnsemble)

# Define a list of all models
models <- list(model_gbm, model_drf)

# Define the metalearner
metalearner <- "h2o.glm.wrapper"

# Use h2oEnsemble::h2o.stack for model stacking
model_stack <- h2o.stack(models = models,
                         metalearner = metalearner,
                         response_frame = h2o_df_train[, target])

# Evalute ensemble performance on test data
print(h2o.ensemble_performance(model_stack, h2o_df_test))



