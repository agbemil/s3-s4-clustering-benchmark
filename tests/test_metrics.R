library(testthat)

source(file.path("R", "metrics.R"))

test_that("NMI is one for identical partitions", {
  labels <- c(1, 1, 2, 2, 3, 3)
  expect_equal(nmi_score(labels, labels), 1, tolerance = 1e-10)
})

test_that("matched accuracy handles label permutation", {
  truth <- c(1, 1, 2, 2, 3, 3)
  predicted <- c(3, 3, 1, 1, 2, 2)
  expect_equal(matched_accuracy(truth, predicted), 1)
})
