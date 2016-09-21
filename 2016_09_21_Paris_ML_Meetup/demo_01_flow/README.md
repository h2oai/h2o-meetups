# H2O Flow (Web Interface) Demo

<br><hr><br>

## Introduction

The following procedures can help you get a basic understanding of the H2O Flow
interactive notebook. Please following the procedures from task one to task four.
After that, free feel to try out different features / settings in Flow.

You can also open and look at `Paris_ML_Meetup_Demo_1.flow` for reference.

<br><hr><br>

## Prerequisite

1. Download and Unzip H2O (see these [intructions](http://www.h2o.ai/download/h2o/desktop)).
2. In terminal: `cd <your H2O folder>` (e.g. h2o-3.10.0.6).
3. In terminal: `java -jar h2o.jar`.

<br><hr><br>

## Task 1 - Importing Data from URL

1. In the Flow menu: `Data` -> `Import Files...`.
2. Enter this URL in Search: `http://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv`.
3. Click on the `magnifier icon` to search.
3. Add the CSV file.
4. Click on `Import` button (next to `Actions`).
5. Click on `Parse these files...` button.
6. Change field `quality` (the bottom item) from `Numeric` to `Enum` (for Classification).
7. Click on `Parse`.
8. `View` the data.
9. Click on `quality` to look at data summary charts.
10. Click on other fields to check their summary.

<br><hr><br>

## Task 2 - Splitting Data into Training / Validation / Test

1. In the Flow menu: `Data` -> `Split Frame`.
2. In the Frame drop-down list, select `winequality_white.hex`.
3. Click on `Add a new split`.
4. Enter ratios `0.8`, `0.15` and the third one will be filled automatically.
5. Enter keys `training_frame`, `validation_frame` and `test_frame` respectively.
6. Enter a random seed number of your choice (e.g. `1234`)
7. click on `Create`.


<br><hr><br>

## Task 3 - Build a Gradient Boosting Machines (GBM) Model with Default Settings

1. In the Flow menu: `Model` -> `Gradient Boosting Method`.
2. Select `training_frame` as the training_frame.
3. Select `validation_frame` as the validation_frame.
4. Select `quality` as the response_column.
5. Scroll down and click on `Build Model` button.
6. `View` the model.


<br><hr><br>

## Task 4 - Use the Model for Predictions

1. In the Flow menu: `Score` -> `Predict`.
2. Select the model (e.g. `gbm-xxx-xxx-xxx`)
3. Select `test_frame` as Frame.
4. Click on `Predict`.


<br><hr><br>

## Try your own 

The above four tasks will give you a taste of the basics. Now it is your time to
try different settings / models / workflow. 

For example:

- `Model` -> `Deep Learning`
- `Data` -> `Upload File`
- `Flow` -> `Save Flow`

<br><hr><br>








