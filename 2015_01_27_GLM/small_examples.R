df = iris
df$is_setosa = df$Species == 'setosa'

library(h2o)
h = h2o.init()
h2odf = as.h2o(h, df)

# Y is a T/F value
y = 'is_setosa'
x = c("Sepal.Length", "Sepal.Width",
      "Petal.Length", "Petal.Width")
binary_classification_model =
  h2o.glm(data = h2odf, y = y, x = x, family = "binomial")

# Y is a real value
y = 'Sepal.Length'
x = c("Sepal.Width",
      "Petal.Length", "Petal.Width")
numeric_regression_model =
  h2o.glm(data = h2odf, y = y, x = x, family = "gaussian")


y = 'is_setosa'
x = c("Sepal.Length", "Sepal.Width",
      "Petal.Length", "Petal.Width")
model_with_5folds = h2o.glm(data = h2odf, y = y, x = x, family = "binomial", nfolds = 5)
print(model_with_5folds@model$auc)
print(model_with_5folds@xval[[1]]@model$auc)
print(model_with_5folds@xval[[2]]@model$auc)
print(model_with_5folds@xval[[3]]@model$auc)
print(model_with_5folds@xval[[4]]@model$auc)
print(model_with_5folds@xval[[5]]@model$auc)
