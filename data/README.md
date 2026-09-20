# Data

This project uses the **S3** and **S4** datasets from the University of Eastern
Finland clustering benchmark collection.

Official source:

https://cs.uef.fi/sipu/datasets/

The S-sets are synthetic two-dimensional benchmarks containing:

- 5,000 observations per dataset
- 15 Gaussian clusters
- progressively stronger cluster overlap from S1 through S4

For this repository, place the following files in this directory:

```text
data/
├── s3.txt
├── s3-label.txt
├── s3-cb.txt
├── s4.txt
├── s4-label.txt
└── s4-cb.txt
```

The raw benchmark files are not bundled in this portfolio package. Download
them from the official benchmark source and preserve the original citation.

## References

Fränti, P., & Virmajoki, O. (2006). Iterative shrinking method for clustering
problems. *Pattern Recognition, 39*(5), 761–765.

Fränti, P., & Sieranoja, S. (2018). K-means properties on six clustering
benchmark datasets. *Applied Intelligence, 48*, 4743–4759.
