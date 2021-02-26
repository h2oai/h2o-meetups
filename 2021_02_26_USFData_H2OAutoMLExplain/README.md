# USF Data Institute

Date: February 26, 2021

Location: Online

[USF Seminar Series in Data Science](https://www.meetup.com/USF-Seminar-Series-in-Data-Science/events/274520354/)

## Talk: Automatic & Explainable Machine Learning in with H2O

H2O is an open source, distributed machine learning platform, designed to scale to very large datasets. H2O AutoML provides an easy-to-use interface (available in Python, R, Java and Scala) which automates data pre-processing, training and tuning a large selection of candidate models from a single function. The result of the AutoML run is a "leaderboard" of H2O models, which can be then be explained automatically using the newly released H2O Explainability interface.

The models can be explained individually, and also compared as a group, with global (model-wise) and local (row-wise) explanations are available. The `h2o.explain()` function generates a list of explanations – individual units of explanation such as a Partial Dependence plot or a Variable Importance plot. Most of the explanations are visual – these plots can also be created by individual utility functions outside of the primary explain function. The visualization engine used in the R interface is ggplot2, and in Python, we use matplotlib.

Demo code & more information is provided in the links below, which can be used to automatically train and explain models on your own datasets.

- H2O AutoML: [http://docs.h2o.ai/h2o/latest-stable/h2o-docs/automl.html](http://docs.h2o.ai/h2o/latest-stable/h2o-docs/automl.html)
- H2O Explain: [http://docs.h2o.ai/h2o/latest-stable/h2o-docs/explain.html](http://docs.h2o.ai/h2o/latest-stable/h2o-docs/explain.html)


### About Erin:

Erin LeDell is the Chief Machine Learning Scientist at H2O.ai, the company that produces the open source, distributed machine learning platform, H2O. At H2O.ai, she leads the H2O AutoML project and her current research focus is automated machine learning. Before joining H2O.ai, she was the Principal Data Scientist at Wise.io (acquired by GE) and Marvin Mobile Security (acquired by Veracode), the founder of DataScientific, Inc. and a software engineer. She is also founder of the Women in Machine Learning and Data Science (WiMLDS) organization (wimlds.org) and co-founder of R-Ladies Global (rladies.org). Erin received her Ph.D. in Biostatistics with a Designated Emphasis in Computational Science and Engineering from University of California, Berkeley and has a B.S. and M.A. in Mathematics.