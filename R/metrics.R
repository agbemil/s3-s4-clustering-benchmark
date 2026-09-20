# Evaluation utilities for clustering benchmark experiments.

nmi_score <- function(truth, predicted) {
  tab <- table(truth, predicted)
  n <- sum(tab)

  p_ij <- tab / n
  p_i <- rowSums(p_ij)
  p_j <- colSums(p_ij)

  mi <- 0
  for (i in seq_len(nrow(p_ij))) {
    for (j in seq_len(ncol(p_ij))) {
      if (p_ij[i, j] > 0) {
        mi <- mi + p_ij[i, j] *
          log(p_ij[i, j] / (p_i[i] * p_j[j]))
      }
    }
  }

  h_i <- -sum(p_i[p_i > 0] * log(p_i[p_i > 0]))
  h_j <- -sum(p_j[p_j > 0] * log(p_j[p_j > 0]))

  if (h_i == 0 || h_j == 0) {
    return(NA_real_)
  }

  mi / sqrt(h_i * h_j)
}


matched_accuracy <- function(truth, predicted) {
  contingency <- table(predicted, truth)
  assignment <- clue::solve_LSAP(contingency, maximum = TRUE)

  total_correct <- 0
  for (i in seq_len(nrow(contingency))) {
    total_correct <- total_correct + contingency[i, assignment[i]]
  }

  total_correct / length(truth)
}


centroid_rmse <- function(x, predicted, ground_truth_centroids) {
  cluster_ids <- sort(unique(predicted[predicted != 0]))

  if (length(cluster_ids) != nrow(ground_truth_centroids)) {
    return(NA_real_)
  }

  estimated <- do.call(
    rbind,
    lapply(cluster_ids, function(cluster_id) {
      colMeans(x[predicted == cluster_id, , drop = FALSE])
    })
  )

  distance_matrix <- as.matrix(
    stats::dist(rbind(estimated, ground_truth_centroids))
  )

  k <- nrow(estimated)
  cross_distances <- distance_matrix[
    seq_len(k),
    k + seq_len(k),
    drop = FALSE
  ]

  assignment <- clue::solve_LSAP(cross_distances)

  matched_distances <- vapply(
    seq_len(k),
    function(i) cross_distances[i, assignment[i]],
    numeric(1)
  )

  sqrt(mean(matched_distances^2))
}


silhouette_mean <- function(x, predicted) {
  keep <- predicted != 0
  labels <- predicted[keep]

  if (length(unique(labels)) < 2) {
    return(NA_real_)
  }

  sil <- cluster::silhouette(
    labels,
    stats::dist(x[keep, , drop = FALSE])
  )

  mean(sil[, "sil_width"])
}


evaluate_clustering <- function(
  dataset_name,
  method_name,
  x,
  truth,
  predicted,
  elapsed_seconds,
  ground_truth_centroids
) {
  non_noise <- predicted[predicted != 0]

  data.frame(
    Dataset = dataset_name,
    Method = method_name,
    ARI = mclust::adjustedRandIndex(truth, predicted),
    NMI = nmi_score(truth, predicted),
    Silhouette = silhouette_mean(x, predicted),
    Matched_Accuracy = matched_accuracy(truth, predicted),
    Centroid_RMSE = centroid_rmse(
      x,
      predicted,
      ground_truth_centroids
    ),
    Predicted_Clusters = length(unique(non_noise)),
    Noise_Fraction = mean(predicted == 0),
    Runtime_Seconds = elapsed_seconds,
    stringsAsFactors = FALSE
  )
}
