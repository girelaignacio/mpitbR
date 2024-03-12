
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mpitbR: A Toolbox for Calculating Multidimensional Poverty Indices in R

<!-- badges: start -->
<!-- badges: end -->

Here it is provided a package for estimating multidimensional poverty
measures based on the Alkire-Foster method which mirrors the estimation
procedures of the original mpitb Stata package.

## Installation

You can install the development version of mpitbR from
[GitHub](https://github.com/girelaignacio/mpitbR) or installing it from
CRAN.

``` r
# Define the package name
package_name <- "mpitbR"

# If the package is not available on CRAN, try installing it from GitHub
if (!require(package_name, character.only = TRUE)) {
  devtools::install_github("girelaignacio/mpitbR")
}
#> Loading required package: mpitbR

# Try installing the package from CRAN
if (!require(package_name, character.only = TRUE)) {
  install.packages(package_name)
}
```

This process may take time the first time.

------------------------------------------------------------------------
