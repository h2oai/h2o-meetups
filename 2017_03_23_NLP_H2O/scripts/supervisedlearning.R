
############ The purpose of this script is to train a model that predicts movie genre.

## Initialize h2o cluster
library('h2o')
h2o.init()

##### Create Model Data

## Import Movie Data
movie_data <- h2o.importFile("data/model_data_no_embeddings.csv.zip", header = TRUE)

library('tm')
STOP_WORDS <- stopwords(kind = "en")

tokenize <- function(sentences, stop.words = STOP_WORDS) {
  tokenized <- h2o.tokenize(sentences, "\\\\W+")
  
  # convert to lower case
  tokenized.lower <- h2o.tolower(tokenized)
  # remove short words (less than 2 characters)
  tokenized.lengths <- h2o.nchar(tokenized.lower)
  tokenized.filtered <- tokenized.lower[is.na(tokenized.lengths) || tokenized.lengths >= 2,]
  
  # remove stop words
  tokenized.filtered[is.na(tokenized.filtered) || (! tokenized.filtered %in% STOP_WORDS),]
}

words <- tokenize(movie_data$plot)

##### Import Word2Vec Models

## Import Pretrained Glove Model

# Glove model can be downloaded from the following website: https://nlp.stanford.edu/projects/glove/
# Download the glove.6B.zip

g6B <- h2o.importFile("glove/glove.6B.100d.txt", header = FALSE, na.strings = NA, sep = " ")

glove_g6B <- h2o.word2vec(pre_trained = g6B, vec_size = 100)

##### Create Word Embeddings per Movie and add to the data

aggregated_pretrained <- h2o.transform(glove_g6B, words, aggregate_method = "AVERAGE")

movie_data$plot <- NULL
movie_data <- h2o.cbind(movie_data, aggregated_pretrained)

## Load Our W2Vec Model
## You can build your own word2vec model by following the w2vtraining.R script

w2v_model <- h2o.loadModel("models/h2o_w2v.hex")

##### Create Word Embeddings per Movie and add to the data

aggregated_h2o <- h2o.transform(w2v_model, words, aggregate_method = "AVERAGE")
colnames(aggregated_h2o) <- paste0("h2o_", colnames(aggregated_h2o))

movie_data <- h2o.cbind(movie_data, aggregated_h2o)

## Split Data
split_data <- h2o.splitFrame(movie_data, ratios = 0.75, 
                             destination_frames = c("train.hex", "test.hex"), seed = 1234)
train <- split_data[[1]]
test <- split_data[[2]]

# Build Default GBM model with Glove Word Embeddings
myX <- paste0("C", c(1:100))
gbm_model <- h2o.gbm(x = myX, y = "genre", 
                     training_frame = train, validation_frame = test,
                     model_id = "gbm_model.hex")


# Add H2O Word Embeddings
myX <- c(myX, paste0("h2o_C", c(1:100)))
gbm_model_h2ow2v <- h2o.gbm(x = myX, y = "genre", 
                     training_frame = train, validation_frame = test,
                     model_id = "gbm_model_h2ow2v.hex")


# Compare Results

round(h2o.mean_per_class_error(gbm_model, valid = TRUE), digits = 3)
round(h2o.mean_per_class_error(gbm_model_h2ow2v, valid = TRUE), digits = 3)

# Early stopping
gbm_model_es <- h2o.gbm(x = myX, y = "genre",
                        training_frame = train, validation_frame = test,
                        model_id = "gbm_early_stopping.hex",
                        ntrees = 1000,
                        stopping_rounds = 5, stopping_metric = "mean_per_class_error",
                        stopping_tolerance = 0.001,
                        score_tree_interval = 5)

round(h2o.mean_per_class_error(gbm_model_es, valid = TRUE), digits = 3)

# Grid Search

## Note: Grid Search will take a lot of memory.  Feel free to skip this step if you are running on your laptop.
hyper_params = list( 
  ## restrict the search to the range of max_depth established above
  max_depth = seq(1, 20, 2),                                     
  
  ## search a large space of row sampling rates per tree
  sample_rate = seq(0.2, 1, 0.01),                                             
  
  ## search a large space of column sampling rates per tree
  col_sample_rate_per_tree = seq(0.2, 1, 0.01),                                
  
  ## search a large space of the number of min rows in a terminal node
  min_rows = c(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048),                                
  
  ## try all histogram types (QuantilesGlobal and RoundRobin are good for numeric columns with outliers)
  histogram_type = c("UniformAdaptive", "QuantilesGlobal")       
)

search_criteria = list(
  ## Random grid search
  strategy = "RandomDiscrete",      
  
  ## limit the runtime to 60 minutes
  max_runtime_secs = 3600,         
  
  ## build no more than 100 models
  max_models = 100,                  
  
  ## random number generator seed to make sampling of parameter combinations reproducible
  seed = 1234,                        
  
  ## early stopping once the leaderboard of the top 5 models is converged to 0.1% relative difference
  stopping_rounds = 5,                
  stopping_metric = "mean_per_class_error",
  stopping_tolerance = 1e-3
)

grid <- h2o.grid(
  ## hyper parameters
  hyper_params = hyper_params,
  
  ## hyper-parameter search configuration (see above)
  search_criteria = search_criteria,
  
  ## which algorithm to run
  algorithm = "gbm",
  
  ## identifier for the grid, to later retrieve it
  grid_id = "final_grid", 
  
  ## standard model parameters
  x = myX, 
  y = "genre", 
  training_frame = train, 
  validation_frame = test,
  
  ## more trees is better if the learning rate is small enough
  ## use "more than enough" trees - we have early stopping
  ntrees = 10000,                                                            
  
  ## smaller learning rate is better
  ## since we have learning_rate_annealing, we can afford to start with a bigger learning rate
  learn_rate = 0.1,                                                         
  
  ## learning rate annealing: learning_rate shrinks by 1% after every tree 
  ## (use 1.00 to disable, but then lower the learning_rate)
  learn_rate_annealing = 0.99,                                               
  
  ## early stopping once the validation mean_per_class_error doesn't improve by at least 0.1% for 5 consecutive scoring events
  stopping_rounds = 5, stopping_tolerance = 0.001, stopping_metric = "mean_per_class_error", 
  
  ## score every 10 trees to make early stopping reproducible (it depends on the scoring interval)
  score_tree_interval = 10,                                                
  
  ## base random number generator seed for each model (automatically gets incremented internally for each model)
  seed = 1234                                                             
)

## Sort the grid models by mean per class error
sortedGrid <- h2o.getGrid("final_grid", sort_by = "mean_per_class_error", decreasing = TRUE)    
sortedGrid


# Build a function that predicts genre based on plot

library('tm')
STOP_WORDS <- stopwords(kind = "en")

tokenize <- function(sentences, stop.words = STOP_WORDS) {
  tokenized <- h2o.tokenize(sentences, "\\\\W+")
  
  # convert to lower case
  tokenized.lower <- h2o.tolower(tokenized)
  # remove short words (less than 2 characters)
  tokenized.lengths <- h2o.nchar(tokenized.lower)
  tokenized.filtered <- tokenized.lower[is.na(tokenized.lengths) || tokenized.lengths >= 2,]
  
  # remove stop words
  tokenized.filtered[is.na(tokenized.filtered) || (! tokenized.filtered %in% STOP_WORDS),]
}

genrePredictor <- function(plot, supervised_model, h2o_w2v_model, glove_w2v_model){
  
  # Convert Plot to h2o frame
  plot <- as.h2o(data.frame('plot' = plot, stringsAsFactors = FALSE))
  
  # Tokenize Plot
  words <- tokenize(plot)
  
  # Aggregate the word embeddings for the plot
  aggregated_pretrained <- h2o.transform(glove_w2v_model, words, aggregate_method = "AVERAGE")
  
  aggregated_h2o <- h2o.transform(h2o_w2v_model, words, aggregate_method = "AVERAGE")
  colnames(aggregated_h2o) <- paste0("h2o_", colnames(aggregated_h2o))
  
  model_data <- h2o.cbind(aggregated_pretrained, aggregated_h2o)
  
  # Predict using our model
  prediction <- h2o.predict(supervised_model, model_data)
  
  return(prediction)
}


## Try the Genre Predictor

# Best GBM Model
plot <- "It's 2029. Mutants are gone--or very nearly so. An isolated, despondent Logan is drinking his days away in a hideout on a remote stretch of the Mexican border, picking up petty cash as a driver for hire. His companions in exile are the outcast Caliban and an ailing Professor X, whose singular mind is plagued by worsening seizures. But Logan's attempts to hide from the world and his legacy abruptly end when a mysterious woman appears with an urgent request--that Logan shepherd an extraordinary young girl to safety. Soon, the claws come out as Logan must face off against dark forces and a villain from his own past on a live-or-die mission, one that will set the time-worn warrior on a path toward fulfilling his destiny."
genrePredictor(plot, gbm_model_es, w2v_model, glove_g6B)
