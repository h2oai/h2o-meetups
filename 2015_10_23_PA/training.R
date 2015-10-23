# Available at http://bit.ly/1LrCF1I

# load h2o library
library(h2o)
# connect to local h2o or start new
h2o.init(nthreads=-1)

##################
# Very basics of uploading a file and looking at it
##################
irisPath = system.file("extdata", "iris.csv", package="h2o")
# upload file from local computer to h2o and get summary stats
iris.hex = h2o.uploadFile(path=irisPath, destination_frame = "iris.hex")
summary(iris.hex)
# look at the structure of the frame
h2o.anyFactor(iris.hex)
str(iris.hex)

####################
# Various data prep / exploratory 
####################
prosPath = system.file("extdata", "prostate.csv", package="h2o")

# import a file local to the h2o process
prostate.hex = h2o.importFile(path=prosPath)

# is everything the right type?
summary(prostate.hex)
head(prostate.hex)
is.factor(prostate.hex[,4])
prostate.hex[,4] = as.factor(prostate.hex[,4])
is.factor(prostate.hex[,4])
summary(prostate.hex)

# bring the data frame back to R (CAUTION, only do with small data)
prostate.R = as.data.frame(prostate.hex)
# and to H2O
prostate.dup.hex = as.h2o(prostate.R, destination_frame = "prostate.dup.hex")

# what's in h2o
h2o.ls()

# some more info about the h2o frame
colnames(prostate.hex)
names(prostate.hex)
nrow(prostate.hex)
ncol(prostate.hex)

# summary stats
min(prostate.hex$AGE)
max(prostate.hex$AGE)

# quantiles
prostate.qs = quantile(prostate.hex$PSA, probs=(1:10)/10)
prostate.qs

PSA.outliers = prostate.hex[prostate.hex$PSA <= prostate.qs["10%"] |
                            prostate.hex$PSA >= prostate.qs["90%"], ]
PSA.outliers

# add this as a feature
prostate.hex$OUTLIER_PSA = as.factor( prostate.hex$PSA >= prostate.qs["90%"] ) 
prostate.hex$OVERSIXTYFIVE = as.factor(prostate.hex$AGE > 65)

# summarizing data in a table
h2o.table(prostate.hex[,"AGE"])
h2o.table(prostate.hex[,c("OVERSIXTYFIVE","OUTLIER_PSA")])

interaction.hex = h2o.interaction(prostate.hex, factors=c("OUTLIER_PSA","OVERSIXTYFIVE"),
                               pairwise = TRUE, max_factors=100, min_occurrence=1)
interaction.hex
prostate.hex = h2o.cbind(prostate.hex, interaction.hex)
prostate.hex
summary(prostate.hex)
# generating random numbers
s = h2o.runif(prostate.hex, seed = 1)
prostate.train = prostate.hex[s <= 0.8,]
prostate.valid = prostate.hex[s >  0.8,]

# group by, calculating summary for each group
group = h2o.group_by(prostate.train, c("OVERSIXTYFIVE"), 
                     mean("PSA"), sd("PSA"), 
                     gb.control=list(col.names=c("MEAN_PSA", "STDDEV_PSA")))
group

# joining results back to original
prostate.train = h2o.merge(prostate.train, group)
prostate.valid = h2o.merge(prostate.valid, group)

# this is for demonstration purpses
prostate.missing = h2o.insertMissingValues(prostate.dup.hex, fraction=0.1)  # inplace
summary(prostate.missing)
prostate.notmissing=h2o.impute(prostate.missing, "PSA", "mean", by=c("AGE"))
summary(prostate.notmissing)

summary(prostate.hex)

h2o.exportFile(prostate.hex, path = "/Users/hank/x/augmented_prostate.csv")

h2o.shutdown()
##################################
# Modeling
##################################
h2o.init()

airlinesURL = "https://s3.amazonaws.com/h2o-airlines-unpacked/allyears2k.csv"
airlines.hex = h2o.importFile(path=airlinesURL, destination_frame = "airlines.hex")
summary(airlines.hex)

# view quantiles and histogram
quantile(x=airlines.hex$ArrDelay, na.rm=True)
h2o.hist(airlines.hex$ArrDelay)

# find number of flights by airport
originFlights = h2o.table(airlines.hex$Origin)
originFlights.R = as.data.frame(originFlights)
originFlights.R[order(originFlights.R$Count, decreasing=TRUE),] 

# find flights cancellations by month
flightsByMonth = h2o.table(airlines.hex$Month)
colnames(flightsByMonth)[2] <- "Flights"
flightsByMonth.R = as.data.frame(flightsByMonth)
flightsByMonth.R[order(flightsByMonth.R$Flights, decreasing=TRUE),] 

# find months with highest cancellation ratio
fun = function(df) {
  sum(df[,which(colnames(airlines.hex)=="Cancelled")])
}
cancellationsByMonth = h2o.ddply(airlines.hex,"Month", fun)
colnames(cancellationsByMonth)[2] <- "Cancellations"
mergedFlightsCancellations = h2o.merge(cancellationsByMonth, flightsByMonth)
mergedFlightsCancellations["CancellationRate"] = mergedFlightsCancellations$Cancellations/mergedFlightsCancellations$Flights
mergedFlightsCancellations

# Construct test and train splits
airlines.split = h2o.splitFrame(data=airlines.hex, ratios=0.85)
airlines.train = airlines.split[[1]]
airlines.valid = airlines.split[[2]]

# view some data as tables
h2o.table(airlines.train$IsArrDelayed)
h2o.table(airlines.valid$IsArrDelayed)

# set predictor and response variables
Y = "IsArrDelayed"
X = c("Origin","Dest","DayofMonth", "Year", "UniqueCarrier", "DayOfWeek", "Month", "CRSDepTime","CRSArrTime","CRSElapsedTime")

# create model
airlines.glm = h2o.glm(training_frame = airlines.train, 
                       validation_frame = airlines.valid,
                       x=X, y=Y, family="binomial", alpha=0.5)

# display the results
summary(airlines.glm)

# Make some predictions
pred = predict(airlines.glm, airlines.valid)
summary(pred)
head(pred)

# Save for scoring
h2o.download_pojo(airlines.glm, path="/Users/hank/x", getjar=TRUE)

# Logs (for debugging)
h2o.downloadAllLogs(dirname="/Users/hank/x/",filename="h2ologs.zip")

###########################
# GBM
###########################

iris.hex

iris.gbm <- h2o.gbm(y=1, x=2:5, training_frame = iris.hex, n_trees=10, max_depth=3, min_rows=2, learn_rate=0.2, distribution="gaussian")
summary(iris.gbm)
iris.gbm@model$scoring_history

iris.gbm2 <- h2o.gbm(y=5, x=1:4, training_frame = iris.hex, ntrees=10, max_depth=3, min_rows=2, learn_rate=0.2, distribution="multinomial")
summary(iris.gbm2)
iris.gbm2@model$training_metrics

#######
# Kmeans
#######
iris.kmeans = h2o.kmeans(training_frame = iris.hex, k=3, x=1:4)

####
# Pr Comp
####
ausPath = system.file("extdata", "australia.csv", package="h2o")
australia.hex = h2o.importFile(path = ausPath)
australia.pca = h2o.prcomp(training_frame = australia.hex, transform = "STANDARDIZE", k=3)
summary(australia.pca)

australia.reduced = predict(australia.pca, australia.hex)

######
# Grid search
######
ntrees_opt <- list(5,10,15)
maxdepth_opt <- list(2,3,4)
learnrate_opt <- list(0.1,0.2)
hyper_parameters <- list(ntrees=ntrees_opt, max_depth=maxdepth_opt, learn_rate=learnrate_opt)

grid <- h2o.grid("gbm", hyper_params = hyper_parameters, y = Y, x = X, distribution="bernoulli", training_frame = airlines.train, validation_frame = airlines.valid)

grid
