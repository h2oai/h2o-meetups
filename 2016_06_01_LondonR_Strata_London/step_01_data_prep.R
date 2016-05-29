# Kaggle Shelter Animal Outcomes
# Data Prep

# ------------------------------------------------------------------------------
# Libraries
# ------------------------------------------------------------------------------

suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(dummies))

# ------------------------------------------------------------------------------
# Import
# ------------------------------------------------------------------------------

# Note: set working dir to the root of this folder
d_train <- fread("train_data_from_kaggle.csv", data.table = FALSE)
d_test <- fread("test_data_from_kaggle.csv", data.table = FALSE)

# ------------------------------------------------------------------------------
# Features Engineering Ref:
# https://www.kaggle.com/hamelg/shelter-animal-outcomes/xgboost-w-breed-color-feats/code
# https://www.kaggle.com/mrisdal/shelter-animal-outcomes/quick-dirty-randomforest
# ------------------------------------------------------------------------------

# Add empty targets to d_test
d_test$OutcomeType <- ""

# Define features and targets
features_raw <- colnames(d_test)

# Rename Animal ID
colnames(d_train)[1] <- "ID"

# Remove row with missing sex label
# only one row in d_train
d_train <- d_train[-which(d_train$SexuponOutcome == ""),]

# Combine d_train and d_test
d_all <- rbind(d_train[, features_raw], d_test[, features_raw])

# Add some date/time-related variables
d_all$DateTime <- as.POSIXct(d_all$DateTime)
d_all$year <- year(d_all$DateTime)
d_all$month <- month(d_all$DateTime)
d_all$wday <- wday(d_all$DateTime)
d_all$hour <- hour(d_all$DateTime)
d_all$DateTimeNum <- as.numeric(d_all$DateTime)

# Time (factor)
d_all$TimeOfDay <- "Unknown"
d_all[which(d_all$hour >= 5 & d_all$hour < 12), ]$TimeOfDay <- "Morning"
d_all[which(d_all$hour >= 12 & d_all$hour < 13), ]$TimeOfDay <- "Noon"
d_all[which(d_all$hour >= 13 & d_all$hour < 18), ]$TimeOfDay <- "Afternoon"
d_all[which(d_all$hour >= 18 & d_all$hour < 21), ]$TimeOfDay <- "Evening"
d_all[which(d_all$hour >= 21 & d_all$hour <= 23), ]$TimeOfDay <- "Night"
d_all[which(d_all$hour >= 0 & d_all$hour < 5), ]$TimeOfDay <- "Night"

# A function to convert age outcome to numeric age in days
convert_age <- function(age_outcome){
  split <- strsplit(as.character(age_outcome), split=" ")
  period <- split[[1]][2]
  if (grepl("year", period)){
    per_mod <- 356
  } else if (grepl("month", period)){
    per_mod <- 30
  } else if (grepl("week", period)){
    per_mod <- 7
  } else
    per_mod <- 1
  age <- as.numeric(split[[1]][1]) * per_mod
  return(age)
}

# Convert age into num of days
d_all$AgeNum <- sapply(d_all$AgeuponOutcome, FUN = convert_age)
d_all[is.na(d_all)] <- 0 # Fill NA with 0

# Add var for name length
d_all$name_len <- sapply(as.character(d_all$Name), nchar)

# Simple Breed
d_all$IsMix <- 0
d_all[str_detect(d_all$Breed, "Mix"), ]$IsMix <- 1

# # Simple Color
d_all$SimpleColor <- sapply(d_all$Color, function(x) strsplit(x, split = '/| ')[[1]][1])

# Convert year month wday hour into factor
d_all$year <- as.factor(d_all$year)
d_all$month <- as.factor(d_all$month)
d_all$wday <- as.factor(d_all$wday)
d_all$hour <- as.factor(d_all$hour)


# ------------------------------------------------------------------------------
# Dummies variable
# ------------------------------------------------------------------------------

# dummies for y
y_train <- d_all[1:nrow(d_train), which(colnames(d_all) %in% c("ID", "OutcomeType"))]
y_train_dummy <- dummy.data.frame(data.frame(y_train$OutcomeType))
colnames(y_train_dummy) <- c("Adoption", "Died", "Euthanasia", "Return_to_owner", "Transfer")
y_train <- cbind(y_train, y_train_dummy)

# dummies for x
col_ignore <- which(colnames(d_all) %in%
                      c("ID", "Name", "DateTime", "AgeuponOutcome", "Breed", "Color",
                        "OutcomeType"))
features_core <- colnames(d_all)[-col_ignore]
x_dummy <- data.frame(ID = d_all$ID, dummy.data.frame(d_all[, features_core]),
                      stringsAsFactors = FALSE) # for xgboost / svm etc.

# ------------------------------------------------------------------------------
# Convert chr to factor
# ------------------------------------------------------------------------------

x_factor <- d_all[, features_core]
for (n_col in 1:ncol(x_factor)) {
  if (class(x_factor[, n_col]) == "character")
    x_factor[, n_col] <- as.factor(x_factor[, n_col])
}

x_factor <- data.frame(ID = d_all$ID, x_factor, stringsAsFactors = FALSE)

# ------------------------------------------------------------------------------
# Split, return outputs and clean up
# ------------------------------------------------------------------------------

y_train$OutcomeType <- as.factor(y_train$OutcomeType)

x_ftr_train <- x_factor[1:nrow(d_train), ]
x_ftr_test <- x_factor[-1:-nrow(d_train), ]

x_num_train <- x_dummy[1:nrow(d_train), ]
x_num_test <- x_dummy[-1:-nrow(d_train), ]

# Clean up
# rm(list=ls(pattern="^d_"))
# rm(list=ls(pattern="^features"))
# rm(list=ls(pattern="^train"))
# rm(list=ls(pattern="^test"))
# rm(list=ls(pattern="^all"))
# rm(list=ls(pattern="^col"))
# rm(list=ls(pattern="^breed"))
# rm(x_dummy, x_factor, y_train_dummy, convert_age, n_col)
