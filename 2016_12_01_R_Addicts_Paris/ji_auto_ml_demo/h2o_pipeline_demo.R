library(readr)
library(doMC)

registerDoMC(cores = 3)
train <- read_csv("input/train.csv") # download data from Kaggle https://www.kaggle.com/c/bnp-paribas-cardif-claims-management/data
test <- read_csv("input/test.csv") # download data from Kaggle https://www.kaggle.com/c/bnp-paribas-cardif-claims-management/data
summary(train)
summary(test)
train$target<-as.factor(train$target)
class_col<-unlist(lapply(train, class))

drop.col<-c()
for(i in 1:dim(train)[2]){
  if(class_col[i] == "character"){
    print(colnames(train)[i])
    print(dim(unique(train[,i]))[1])
    if(dim(unique(train[,i]))[1]>50){
      print(colnames(train)[i])
      drop.col<-c(drop.col,colnames(train)[i])
    }
  }
}
print(drop.col)
train<-train[,-which(colnames(train) %in% drop.col)]
test<-test[,-which(colnames(test) %in% drop.col)]

library(VIM)
plotmiss<-aggr(train,numbers=T,combined = T,border="gray50",sortVars=T,labels=names(train))

library(h2o)
h2o.init(nthreads = -1)
train.hex<-as.h2o(train,destination_frame = "train.hex")
test.hex<-as.h2o(test,destination_frame = "test.hex")
data.glrm<-h2o.rbind(train.hex[,-2],test.hex)
model.glrm <- h2o.glrm(training_frame = data.glrm, 
                       cols = 2:ncol(data.glrm), k = 5, loss = "Quadratic", 
                       regularization_x = "None", regularization_y = "None",
                       max_iterations = 1000)
plot(model.glrm)

new_data.hex<-h2o.predict(model.glrm,data.glrm)
new_train.hex<-new_data.hex[1:nrow(train.hex),]
new_test.hex<-new_data.hex[(nrow(train.hex)+1):nrow(data.glrm),]
new_train.hex<-h2o.cbind(train.hex[,1:2],new_train.hex)
new_test.hex<-h2o.cbind(test.hex[,1],new_test.hex)
#########################################
model.dl = h2o.deeplearning(x = 3:ncol(new_train.hex), y = 2,
                            training_frame = new_train.hex,hidden = c(100, 200), epochs = 5)
train.deepfeatures_layer1 = h2o.deepfeatures(model.dl, new_train.hex, layer = 1)
train.deepfeatures_layer2 = h2o.deepfeatures(model.dl, new_train.hex, layer = 2)
head(train.deepfeatures_layer1)
head(train.deepfeatures_layer2)
test.deepfeatures_layer1=h2o.deepfeatures(model.dl, new_test.hex, layer = 1)
test.deepfeatures_layer2=h2o.deepfeatures(model.dl, new_test.hex, layer = 2)
############################################
# Construct a large Cartesian hyper-parameter space
ntrees_opt <- seq(1,100)
maxdepth_opt <- seq(1,10)
learnrate_opt <- seq(0.001,0.1,0.001)
hyper_parameters <- list(ntrees=ntrees_opt,
                         max_depth=maxdepth_opt,
                         learn_rate=learnrate_opt)

search_criteria = list(strategy = "RandomDiscrete",
                       max_models = 10, 
                       max_runtime_secs = 300, # increase this if needed
                       seed = 123456)

myX=setdiff(colnames(train),c("target","ID")) 

grid <- h2o.grid("gbm", hyper_params = hyper_parameters,
                 search_criteria = search_criteria,
                 grid_id = "mygrid",nfolds=5,
                 y = "target", x = myX, distribution="bernoulli",
                 training_frame = train.hex)

gbm_sorted_grid <- h2o.getGrid(grid_id = "mygrid", sort_by = "logloss")
print(gbm_sorted_grid)

best_model <- h2o.getModel(gbm_sorted_grid@model_ids[[1]])
summary(best_model)
###################################################################

library(h2oEnsemble)  
# Specify the base learner library & the metalearner
learner <- c("h2o.glm.wrapper", "h2o.randomForest.wrapper", 
             "h2o.gbm.wrapper", "h2o.deeplearning.wrapper")
metalearner <- "h2o.deeplearning.wrapper"


# Train the ensemble using 5-fold CV to generate level-one data
# More CV folds will take longer to train, but should increase performance
fit <- h2o.ensemble( x = 3:ncol(train.hex), 
                     y = 2,
                     training_frame = train.hex,
                     family =  "binomial", 
                     learner = learner, 
                     metalearner = metalearner,
                     cvControl = list(V = 5, shuffle = TRUE))


# Compute test set performance:
perf <- h2o.ensemble_performance(fit, newdata = train.hex)

#pred_res<-h2o.predict(fit,newdata = test.hex)
pred_res <- predict(fit,newdata = test.hex) # use predict instead of h2o.predict
head(pred_res)

