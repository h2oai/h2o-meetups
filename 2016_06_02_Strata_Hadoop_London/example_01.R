# Initialise H2O Cluster
library(h2o)
h2o.init(nthreads = -1)

# Load and import mtcars data
data(mtcars)
hex_mtcars <- as.h2o(mtcars)

# Build a GLRM and compress data into a 3-column matrix
glrm_mtcars <- h2o.glrm(training_frame = hex_mtcars,
                        k = 3, seed = 1234)

# Check convergence
plot(glrm_mtcars)


