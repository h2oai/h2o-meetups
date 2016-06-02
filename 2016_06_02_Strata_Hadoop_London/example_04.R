# Initialise H2O Cluster
library(h2o)
h2o.init(nthreads = -1)

# Introduce NA randomly
mtcars_with_na <- mtcars
set.seed(1234)
for (n in 1:176) {
  rand_row <- sample(1:nrow(mtcars_with_na), 1)
  rand_col <- sample(1:ncol(mtcars_with_na), 1)
  mtcars_with_na[rand_row, rand_col] <- NA
}

# Convert to H2O Data Frame
hex_mtcars_na <- as.h2o(mtcars_with_na)

# Build a GLRM using data table with missing values
glrm_mtcars <- h2o.glrm(training_frame = hex_mtcars_na,
                     k = 10, seed = 1234,
                     init = "SVD",
                     regularization_x = "Quadratic",
                     regularization_y = "Quadratic",
                     max_iterations = 100)

# Use GLRM to impute missing values
mtcars_recon <- h2o.predict(glrm_mtcars, hex_mtcars_na)

mtcars_recon <- as.data.frame(mtcars_recon)
colnames(mtcars_recon) <- colnames(mtcars)
rownames(mtcars_recon) <- rownames(mtcars)
mtcars_recon <- round(mtcars_recon, 3)
fea_round2 <- c("drat", "qsec")
fea_round1 <- c("mpg", "disp")
fea_round0 <- c("cyl", "vs", "am", "gear", "carb", "hp")
mtcars_recon[, fea_round0] <- round(mtcars_recon[, fea_round0], 0)
mtcars_recon[, fea_round1] <- round(mtcars_recon[, fea_round1], 1)
mtcars_recon[, fea_round2] <- round(mtcars_recon[, fea_round2], 2)

# Diff
round(mtcars_recon - mtcars, 1)
