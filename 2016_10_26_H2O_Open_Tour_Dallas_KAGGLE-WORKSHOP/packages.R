# This will check if packages are installed and install them if they are not

pkgTest <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}

pkgTest("data.table")
pkgTest("zoo")
pkgTest("caret")
pkgTest("gtools")
pkgTest("sqldf")
pkgTest("doParallel")
pkgTest("doRNG")
pkgTest("VGAM")
pkgTest("xgboost")
pkgTest("readr")
pkgTest("Matrix")
pkgTest("Amelia")