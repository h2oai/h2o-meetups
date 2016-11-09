## Deep Water Demo


# Using nightly build
library(h2o)

# Connect to H2O Deep Water Edition
h2o.init(strict_version_check = FALSE)


# Import CSV
df <- h2o.importFile("./bigdata/laptop/deepwater/imagenet/cat_dog_mouse.csv")
print(head(df))


# Define path and response
path <- 1 
response <- 2


# Train a LeNet with basic parameters
model <- h2o.deepwater(x = path, 
                       y = response, 
                       training_frame = df, 
                       epochs = 300,
                       learning_rate = 1e-3,
                       network = "lenet")
model


# Check out all available parameters
?h2o.deepwater


# Create your own LeNet structure
get_symbol <- function(num_classes = 1000) {
  
  library(mxnet)
  data <- mx.symbol.Variable('data')
  # first conv
  conv1 <- mx.symbol.Convolution(data = data, kernel = c(5, 5), num_filter = 20)
  tanh1 <- mx.symbol.Activation(data = conv1, act_type = "tanh")
  pool1 <- mx.symbol.Pooling(data = tanh1, pool_type = "max", kernel = c(2, 2), stride = c(2, 2))
  
  # second conv
  conv2 <- mx.symbol.Convolution(data = pool1, kernel = c(5, 5), num_filter = 50)
  tanh2 <- mx.symbol.Activation(data = conv2, act_type = "tanh")
  pool2 <- mx.symbol.Pooling(data = tanh2, pool_type = "max", kernel = c(2, 2), stride = c(2, 2))
  
  # first fullc
  flatten <- mx.symbol.Flatten(data = pool2)
  fc1 <- mx.symbol.FullyConnected(data = flatten, num_hidden = 500)
  tanh3 <- mx.symbol.Activation(data = fc1, act_type = "tanh")
  
  # second fullc
  fc2 <- mx.symbol.FullyConnected(data = tanh3, num_hidden = num_classes)
  
  # Output
  lenet <- mx.symbol.SoftmaxOutput(data = fc2, name = 'softmax')
  
  # Return
  return(lenet)
  
}

nclasses = h2o.nlevels(df[,response])
network <- get_symbol(nclasses)
cat(network$as.json(), file = "/tmp/symbol_lenet-R.json", sep = '')


# Show the structure
graph.viz(network$as.json())


# Train the LeNet model again with defined structure
model = h2o.deepwater(x = path, 
                      y = response, 
                      training_frame = df,
                      epochs = 500, ## early stopping is on by default and might trigger before
                      network_definition_file = "/tmp/symbol_lenet-R.json",  ## specify the model
                      image_shape=c(28,28), ## provide expected (or matching) image size
                      channels=3) ## 3 for color, 1 for monochrome
summary(model)
