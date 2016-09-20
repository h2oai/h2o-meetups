# ------------------------------------------------------------------------------
# Paris ML Meetup - H2O Demo 2 (R Interface)
# ------------------------------------------------------------------------------

# This R accompanies the R interface demo at Paris ML Meetup
# https://www.meetup.com/Paris-Machine-learning-applications-group/events/233874278/


# ------------------------------------------------------------------------------
# Prerequisite
# ------------------------------------------------------------------------------

# Install H2O R package (if you haven't done it)
if (FALSE) {
  # The following two commands remove any previously installed H2O packages for R.
  if ("package:h2o" %in% search()) { detach("package:h2o", unload=TRUE) }
  if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }
  
  # Next, we download packages that H2O depends on.
  pkgs <- c("methods","statmod","stats","graphics","RCurl","jsonlite","tools","utils")
  for (pkg in pkgs) {
    if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
  }
}

# Start and connect to a local H2O cluster
library(h2o)
h2o.init(nthreads = -1) # -1 means using all cores
# h2o.no_progress() # if you don't want to see the progress bar, uncomment this


# ------------------------------------------------------------------------------
# Task 1 - Importing Data from URL
# ------------------------------------------------------------------------------

# Import CSV directly from UCI repository
wine_hex <- h2o.importFile("http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv")

# Turn "quality" into categorial variable
wine_hex[, "quality"] <- as.factor(wine_hex[, "quality"])

# Have a quick look at data
head(wine_hex)
summary(wine_hex)


# ------------------------------------------------------------------------------
# Task 2 - Splitting Data into Training / Validation / Test
# ------------------------------------------------------------------------------

# Split (note: try your own random seed number)
split_hex <- h2o.splitFrame(wine_hex, ratios = c(0.8, 0.15), seed = 1234)

# Create three new H2O data frames
# This step is optional as `split_hex` already has the three datasets
# but it helps beginners to better understand the following two tasks
training_frame <- split_hex[[1]]
validation_frame <- split_hex[[2]]
test_frame <- split_hex[[3]]


# ------------------------------------------------------------------------------
# Task 3 - Build a Gradient Boosting Machines (GBM) Model with Default Settings
# ------------------------------------------------------------------------------

# Define features (predictors) and response
response <- "quality"
features <- setdiff(colnames(training_frame), response)
print(features)
print(response)

# Train GBM with default values
model_gbm <- h2o.gbm(x = features,
                     y = response,
                     training_frame = training_frame,
                     validation_frame = validation_frame)

# Look at the model
print(model_gbm)

# Look at the model in details
print(summary(model_gbm))


# ------------------------------------------------------------------------------
# Task 4 - Use the Model for Predictions
# ------------------------------------------------------------------------------

# Predict the "quality" column in test_frame
yhat_test <- h2o.predict(model_gbm, newdata = test_frame)

# Look at the results
print(yhat_test)
h2o.performance(model_gbm, newdata = test_frame)

# Convert the H2O data frame into normal R data frame for other analysis
yhat_test_df <- as.data.frame(yhat_test)


# ------------------------------------------------------------------------------
# Try other stuff
# ------------------------------------------------------------------------------

# Try ...
if (FALSE) {
  
  h2o.deeplearning(...)
  h2o.gbm(..., ntrees = 100, learn_rate = 0.05)
  h2o.splitFrame(..., ratios = c(0.7,0.2))
  
}

