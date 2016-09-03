# ------------------------------------------------------------------------------
# Step 7: Grid Search
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
# Train a GBM with Grid Search
# ------------------------------------------------------------------------------

# Define the number of folds
n_fold <- 5

# Define parameters for grid search
param_gbm <- list(
  max_depth = c(5, 7),
  sample_rate = c(0.8, 0.9),
  ntrees = c(100, 200)
)

# Define criteria for grid search
search_criteria <- list(
  strategy = "Cartesian" # default setting i.e. full grid search
)

# Do a grid search for GBM
grid_gbm <- h2o.grid(

  # Core parameters for model training
  x = features,
  y = target,
  training_frame = h2o_df_boston,
  nfolds = n_fold,

  # Parameters for grid search
  hyper_params = param_gbm,
  search_criteria = search_criteria,
  algorithm = "gbm"

  )

# Grid search results summary
summary(grid_gbm)


# ------------------------------------------------------------------------------
# Extract the best model
# ------------------------------------------------------------------------------

# Extract the IDs of all models
model_ids <- grid_gbm@model_ids
print(model_ids)

# Extract the best model (top of the ID list)
best_gbm <- h2o.getModel(model_ids[[1]])
summary(best_gbm)







