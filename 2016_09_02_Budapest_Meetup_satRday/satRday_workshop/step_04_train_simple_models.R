# ------------------------------------------------------------------------------
# Step 4: Train Simple Models
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Loading data (same as step 3)
# ------------------------------------------------------------------------------

library(mlbench)
data("BostonHousing2")

# Start H2O
library(h2o)
h2o.init(nthreads = -1)

# Import data from R data frame into H2O data frame
h2o_df_boston <- as.h2o(BostonHousing2)


# ------------------------------------------------------------------------------
# Define x (features or predictors) and y (target or response)
# ------------------------------------------------------------------------------

# Define y (target or response) - Corrected Median House Value in USD 1000's
target <- "cmedv"

# Define x (features or predictors)
features <- setdiff(colnames(h2o_df_boston), c("cmedv", "medv"))

# Print them out
cat("Features:", features, "\n")
cat("Target:", target, "\n")


# ------------------------------------------------------------------------------
# Train a vanilla GBM
# ------------------------------------------------------------------------------

# What is GBM?
?h2o.gbm

# Train a GBM with default values
model_gbm <- h2o.gbm(x = features,
                     y = target,
                     training_frame = h2o_df_boston)

# First look
print(model_gbm)

# Model Summary
summary(model_gbm)


# ------------------------------------------------------------------------------
# Try out other models
# ------------------------------------------------------------------------------

# Generalized Linear Model
?h2o.glm
model_glm <- h2o.glm(x = features,
                     y = target,
                     training_frame = h2o_df_boston)
summary(model_glm)


# Distributed Random Forest
?h2o.randomForest
model_drf <- h2o.randomForest(x = features,
                              y = target,
                              training_frame = h2o_df_boston)
summary(model_drf)


# Deep Learning
?h2o.deeplearning
model_dnn <- h2o.deeplearning(x = features,
                              y = target,
                              training_frame = h2o_df_boston)
summary(model_dnn)




