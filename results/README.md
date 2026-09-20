# Results

The committed `original_gmm_baseline.csv` and corresponding figures summarize
the original Gaussian-mixture results recovered from the files supplied with
the project.

Running:

```bash
Rscript run_analysis.R
```

with the official benchmark data placed in `data/` will additionally create:

- `benchmark_results.csv`
- `gmm_bic_model_selection.csv`
- `s3_cluster_assignments.csv`
- `s4_cluster_assignments.csv`
- `ari_method_comparison.png`
- `runtime_comparison.png`

The enhanced benchmark evaluates K-Means, Gaussian Mixture Models, Ward
hierarchical clustering, and HDBSCAN using several complementary metrics.
