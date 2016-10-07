# ------------------------------------------------------------------------------
# Step 2: Data Exploration
# ------------------------------------------------------------------------------

# Start and connect to a local H2O cluster
library(h2o)
h2o.init(nthreads = -1)

# Import data from a local CSV file
# Source: https://archive.ics.uci.edu/ml/machine-learning-databases/secom/
secom <- h2o.importFile(path = "./data/secom.csv", destination_frame = "secom")

# # (Optional) Demo - Importing files using URLs
# secom <- h2o.importFile(
#   path = "https://github.com/woobe/H2O_London_Workshop/raw/master/data/secom.csv",
#   destination_frame = "secom")
#
# # (Optional) Demo - Converting R data frame into H2O data frame
# hdf_iris <- as.h2o(iris)
#
# # (Optional) Turning off progress bar in R
# h2o.no_progress()


# Basic exploratory analysis
print(dim(secom)) # 1567 x 599
print(summary(secom$Classification))
# alternatively, use H2O flow to look at data (localhost:54321)

# Convert Classification to factor
secom$Classification <- as.factor(secom$Classification)
print(summary(secom$Classification))
