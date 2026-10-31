# Chapter 6: Time Series
# Machine Learning in Cardiology: A Practical R-Based Approach
# ILLUSTRATIVE ONLY. Do not source this file: most of these snippets assume
# your own data frames (e.g. echo_data, ecg_data) or files that are not provided.

# --------------------------------------------------------------------------
# Recurrent Neural Networks
# --------------------------------------------------------------------------

# R code example for creating an LSTM model using Keras.
# Requires a working TensorFlow install; not run or tested in this repository.
library(keras)
model <- keras_model_sequential() %>%
  layer_lstm(units = 64, input_shape = c(time_steps, features)) %>%
  layer_dense(units = 1, activation = 'sigmoid')

model %>% compile(
  optimizer = 'adam',
  loss = 'binary_crossentropy',
  metrics = c('accuracy')
)


# --------------------------------------------------------------------------
# Clustering ECG Morphologies
# --------------------------------------------------------------------------

# Assuming 'ecg_data' is a data frame with preprocessed ECG features
# kmeans() is part of base R (the stats package); no library() call is needed.

# Determine the optimal number of clusters using the elbow method
wss <- (nrow(ecg_data)-1)*sum(apply(ecg_data,2,var))
for (i in 2:15) {
  wss[i] <- sum(kmeans(ecg_data,
  centers=i)$withinss)
}
plot(1:15, wss, type="b", xlab="Number of Clusters",
  ylab="Within groups sum of squares")

# Perform k-means clustering with the chosen number of clusters
kmeans_result <- kmeans(ecg_data, centers = 3)

# View the cluster assignments
kmeans_result$cluster

library(factoextra)

# Visualize the clustering results
fviz_cluster(kmeans_result, data = ecg_data,
  ellipse.type = "o",
  geom = "point",
  palette = "jco",
  ggtheme = theme_minimal())
