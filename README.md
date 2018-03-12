# data-jam-march-2018

The dataset used for the March 2018 Data Jam was the set of all car crashes in Harris County from January 2016 to February 2018. The given data was provided in both CSV and RDS formats, though due to time and space concerns, only the RDS format is included here.

The data was used to produce a logit regression model that predicted the probability of a crash leading to a fatality, given only information about the roadway where the collision occurred. This model was then used to assign a predicted probability to each crash in the dataset. Using this predicted value, it was possible to better visualize the roadways on which crashes were most likely to be fatal.

It is likely worth noting that:  
- the model has extraordinarily low predictive power  
- the predicted variables had exceptionally low variance  
- because several predictive variables were recorded only for highways, non-highway roads are excluded from the visualization.

As such, this visualization would be best treated as a sample use-case for visualizing multivariate regression models.

The script produces density maps for each of the following events:  
- accidents involving transit buses  
- weekday and weekend crashes  
- fatal crashes

These were excluded from the repository due to the fact that they were indistinguishable from a map of general population density.

The script also produces scatter plots for weekday and weekend crashes, colored by severity. These failed to yield clear insights, and were likewise excluded from the repository.
