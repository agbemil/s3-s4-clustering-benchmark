# Clustering methods used in the S3/S4 benchmark.

run_kmeans <- function(x, k, seed = 42) {
  set.seed(seed)
  start <- proc.time()[["elapsed"]]

  fit <- stats::kmeans(
    x,
    centers = k,
    nstart = 50,
    iter.max = 1000
  )

  elapsed <- proc.time()[["elapsed"]] - start

  list(
    labels = fit$cluster,
    runtime = elapsed,
    model = fit
  )
}


run_gmm <- function(x, k, seed = 42) {
  set.seed(seed)
  start <- proc.time()[["elapsed"]]

  fit <- mclust::Mclust(
    x,
    G = k,
    verbose = FALSE
  )

  elapsed <- proc.time()[["elapsed"]] - start

  list(
    labels = fit$classification,
    runtime = elapsed,
    model = fit
  )
}


run_ward <- function(x, k) {
  start <- proc.time()[["elapsed"]]

  distance_matrix <- stats::dist(x)
  fit <- stats::hclust(
    distance_matrix,
    method = "ward.D2"
  )
  labels <- stats::cutree(fit, k = k)

  elapsed <- proc.time()[["elapsed"]] - start

  list(
    labels = labels,
    runtime = elapsed,
    model = fit
  )
}


run_hdbscan <- function(x, min_pts = 10) {
  start <- proc.time()[["elapsed"]]

  fit <- dbscan::hdbscan(
    x,
    minPts = min_pts
  )

  elapsed <- proc.time()[["elapsed"]] - start

  list(
    labels = fit$cluster,
    runtime = elapsed,
    model = fit
  )
}


select_gmm_components_by_bic <- function(
  x,
  min_components = 2,
  max_components = 25,
  seed = 42
) {
  set.seed(seed)

  fit <- mclust::Mclust(
    x,
    G = min_components:max_components,
    verbose = FALSE
  )

  list(
    selected_components = fit$G,
    selected_model = fit$modelName,
    bic = fit$bic,
    model = fit
  )
}
