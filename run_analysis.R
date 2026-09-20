# S3/S4 Clustering Benchmark
#
# Compares clustering algorithms under increasing cluster overlap.
# Run from the project root:
#
#   Rscript run_analysis.R

required_packages <- c(
  "mclust",
  "dbscan",
  "cluster",
  "clue",
  "ggplot2"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    paste0(
      "Install missing packages first: ",
      paste(missing_packages, collapse = ", "),
      "\nRun: Rscript install_packages.R"
    )
  )
}

source(file.path("R", "metrics.R"))
source(file.path("R", "benchmark_methods.R"))

dir.create("results", showWarnings = FALSE, recursive = TRUE)

datasets <- list(
  S3 = list(
    data = file.path("data", "s3.txt"),
    labels = file.path("data", "s3-label.txt"),
    centroids = file.path("data", "s3-cb.txt")
  ),
  S4 = list(
    data = file.path("data", "s4.txt"),
    labels = file.path("data", "s4-label.txt"),
    centroids = file.path("data", "s4-cb.txt")
  )
)

all_results <- list()
bic_results <- list()

for (dataset_name in names(datasets)) {
  paths <- datasets[[dataset_name]]

  if (!all(file.exists(unlist(paths)))) {
    stop(
      paste0(
        "Missing data files for ", dataset_name,
        ". See data/README.md for download instructions."
      )
    )
  }

  x_raw <- as.matrix(utils::read.table(paths$data))
  truth <- utils::read.table(paths$labels)[, 1]
  gt_centroids <- as.matrix(utils::read.table(paths$centroids))

  k <- length(unique(truth))

  # Scaling makes distance-based methods directly comparable.
  x <- scale(x_raw)

  fits <- list(
    "K-Means" = run_kmeans(x, k = k),
    "Gaussian Mixture" = run_gmm(x, k = k),
    "Ward Hierarchical" = run_ward(x, k = k),
    "HDBSCAN" = run_hdbscan(x, min_pts = 10)
  )

  dataset_results <- lapply(
    names(fits),
    function(method_name) {
      fit <- fits[[method_name]]

      # Centroid error is computed on the original coordinate scale.
      evaluate_clustering(
        dataset_name = dataset_name,
        method_name = method_name,
        x = x_raw,
        truth = truth,
        predicted = fit$labels,
        elapsed_seconds = fit$runtime,
        ground_truth_centroids = gt_centroids
      )
    }
  )

  all_results[[dataset_name]] <- do.call(
    rbind,
    dataset_results
  )

  # Independent model-selection question:
  # How many components would GMM choose from BIC without being told k=15?
  bic_fit <- select_gmm_components_by_bic(
    x,
    min_components = 2,
    max_components = 25
  )

  bic_results[[dataset_name]] <- data.frame(
    Dataset = dataset_name,
    BIC_Selected_Components = bic_fit$selected_components,
    BIC_Selected_Model = bic_fit$selected_model,
    stringsAsFactors = FALSE
  )

  # Save method-specific cluster assignments.
  assignments <- data.frame(
    X1 = x_raw[, 1],
    X2 = x_raw[, 2],
    GroundTruth = truth
  )

  for (method_name in names(fits)) {
    safe_name <- gsub("[^A-Za-z0-9]+", "_", method_name)
    assignments[[safe_name]] <- fits[[method_name]]$labels
  }

  utils::write.csv(
    assignments,
    file.path(
      "results",
      paste0(tolower(dataset_name), "_cluster_assignments.csv")
    ),
    row.names = FALSE
  )
}

results <- do.call(rbind, all_results)
rownames(results) <- NULL

bic_summary <- do.call(rbind, bic_results)
rownames(bic_summary) <- NULL

utils::write.csv(
  results,
  file.path("results", "benchmark_results.csv"),
  row.names = FALSE
)

utils::write.csv(
  bic_summary,
  file.path("results", "gmm_bic_model_selection.csv"),
  row.names = FALSE
)

# ARI comparison plot.
ari_plot <- ggplot2::ggplot(
  results,
  ggplot2::aes(
    x = Method,
    y = ARI,
    fill = Dataset
  )
) +
  ggplot2::geom_col(
    position = ggplot2::position_dodge(width = 0.8)
  ) +
  ggplot2::coord_cartesian(ylim = c(0, 1)) +
  ggplot2::labs(
    title = "Clustering Accuracy Under Increasing Overlap",
    x = NULL,
    y = "Adjusted Rand Index"
  ) +
  ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(
      angle = 25,
      hjust = 1
    )
  )

ggplot2::ggsave(
  file.path("results", "ari_method_comparison.png"),
  ari_plot,
  width = 9,
  height = 6,
  dpi = 180
)

# Runtime plot.
runtime_plot <- ggplot2::ggplot(
  results,
  ggplot2::aes(
    x = Method,
    y = Runtime_Seconds,
    fill = Dataset
  )
) +
  ggplot2::geom_col(
    position = ggplot2::position_dodge(width = 0.8)
  ) +
  ggplot2::labs(
    title = "Clustering Runtime Comparison",
    x = NULL,
    y = "Runtime (seconds)"
  ) +
  ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(
      angle = 25,
      hjust = 1
    )
  )

ggplot2::ggsave(
  file.path("results", "runtime_comparison.png"),
  runtime_plot,
  width = 9,
  height = 6,
  dpi = 180
)

print(results)
print(bic_summary)
