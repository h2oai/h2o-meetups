# ------------------------------------------------------------------------------
# Step 1: Install R Packages
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Install "mlbench" package for "BostonHousing2" data
# ------------------------------------------------------------------------------

# Install package from CRAN
install.packages("mlbench")

# Quick test
library(mlbench)
data("BostonHousing2")
head(BostonHousing2)


# ------------------------------------------------------------------------------
# Install "h2o" for machine learning
# ------------------------------------------------------------------------------

# Reference: http://www.h2o.ai/download/h2o/r

# The following two commands remove any previously installed H2O packages for R.
if ("package:h2o" %in% search()) { detach("package:h2o", unload=TRUE) }
if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }

# Next, we download packages that H2O depends on.
pkgs <- c("methods","statmod","stats","graphics","RCurl","jsonlite","tools","utils")
for (pkg in pkgs) {
  if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
}

# Now we download, install and initialize the H2O package for R.
install.packages("h2o", type="source", repos=(c("http://h2o-release.s3.amazonaws.com/h2o/rel-turing/6/R")))
library(h2o)
localH2O <- h2o.init(nthreads=-1)


# ------------------------------------------------------------------------------
# Install "h2oEnsemble" for model stacking
# ------------------------------------------------------------------------------

# Reference: https://github.com/h2oai/h2o-3/tree/master/h2o-r/ensemble

# Install stable version (1.8)
install.packages("https://h2o-release.s3.amazonaws.com/h2o-ensemble/R/h2oEnsemble_0.1.8.tar.gz", repos = NULL)

# Quick test
library(h2oEnsemble)

