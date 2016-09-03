# ------------------------------------------------------------------------------
# Step 5: Cross Validation
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
# Train a GBM with n-fold Cross Validation
# ------------------------------------------------------------------------------

# Define the number of folds
n_fold <- 5

# Train a GBM with CV
model_gbm <- h2o.gbm(x = features,
                     y = target,
                     training_frame = h2o_df_boston,
                     nfolds = n_fold) # <--parameter for n-fold CV

# First look
print(model_gbm)

# Model Summary
summary(model_gbm)



