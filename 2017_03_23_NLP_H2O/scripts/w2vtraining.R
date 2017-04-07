
############ The purpose of this script is to train a word2vec model.

library('tm')
library('h2o')
h2o.init(nthreads = -1)

## Import Data
moviesHex <- h2o.importFile("data/model_data_no_embeddings.csv.zip", destination_frame = "movies.hex")

## Word2Vec Algorithm
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

print("Break job titles into sequence of words")
words <- tokenize(moviesHex$plot)

print("Build word2vec model")
w2v.model <- h2o.word2vec(words, sent_sample_rate = 0, epochs = 10, model_id = "h2o_w2v.hex")

print("Sanity check - find synonyms for the word 'date' and 'alien'")
print(h2o.findSynonyms(w2v.model, "date", count = 5))
print(h2o.findSynonyms(w2v.model, "alien", count = 5))


print("Calculate a vector for each movie")
movie.vecs <- h2o.transform(w2v.model, words, aggregate_method = "AVERAGE")

print("Save the word2vec model")
h2o.saveModel(w2v.model, "models")
