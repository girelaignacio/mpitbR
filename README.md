
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mpitbR: A Toolbox for Calculating Multidimensional Poverty Indices in R

<img src="man/figures/hex_sticker_mpitbR2.png" align="right" height="139"/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/girelaignacio/mpitbR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/girelaignacio/mpitbR/actions/workflows/R-CMD-check.yaml)
[![](https://cranlogs.r-pkg.org/badges/grand-total/mpitbR)](https://cran.r-project.org/package=mpitbR)

<!-- badges: end -->

Here it is provided a package for estimating multidimensional poverty
measures based on the Alkire-Foster method which mirrors the estimation
procedures of the original
<tt>[mpitb](https://doi.org/10.1177/1536867X231195286)</tt> Stata
package.

### Installation

You can install the development version of mpitbR from
[GitHub](https://github.com/girelaignacio/mpitbR) or installing it from
CRAN.

``` r
# Install the package from CRAN
install.packages("mpitbR")

# Install the latest version of the package from Github
devtools::install_github("girelaignacio/mpitbR")
```

### Usage

A short example:

``` r
# Here we use the same synthetic household survey-like dataset from the Stata package example
data <- subset(syn_cdta)
data <- na.omit(data)

# Define the survey structure
svydata <- survey::svydesign(id=~psu, weights = ~weight, strata = ~stratum, data = data)

# mpitb set command
  # First we define the indicators with their dimensions names (d1,d2,d3) as a list 
indicators <- list(d1 = c("d_nutr","d_cm"),
                   d2 = c("d_satt","d_educ"),
                   d3 = c("d_elct","d_sani","d_wtr","d_hsg","d_ckfl","d_asst"))
  # Set the multidimensional poverty measurement project
set <- mpitb.set(svydata, indicators = indicators, name = "myname", desc = "pref. desc")

# mpitb est command
  # Estimate! 
est <- mpitb.est(set, c(20, 33), over = c("area","region"), 
                 tvar = "t", cotyear = "year")
```

### Citation

Please cite this package if used in publications:

Girela, Ignacio (2024). *mpitbR: Calculate Alkire-Foster
Multidimensional Poverty Measures*. R package version 1.0.0,
<https://CRAN.R-project.org/package=mpitbR>.

A BibTeX entry for LaTeX users is

``` r
@Manual{mpitbR1.0.0,
    title = {mpitbR: Calculate Alkire-Foster Multidimensional Poverty Measures},
    author = {Ignacio Girela},
    year = {2024},
    note = {R package version 1.0.0},
    url = {https://CRAN.R-project.org/package=mpitbR},
  }
```

### License

This project is licensed under the [GPL (\>=
3)](https://www.fsf.org/news/gplv3_launched)

### Documentation

For more detailed information, please refer to the documentation.

### Contributing

Contributions are welcome! Please open an issue or submit a pull request

### Contact

Please, do not hesitate to contact me!

Ignacio Girela (📧 <ignacio.girela@unc.edu.ar>)

## Some comparisons with the original Stata package

The equivalent command of the previous example in the <tt>mpitb</tt>
Stata package is the following:

> mpitb est, name(trial01) measures(all) /// indmeasures(all) aux(all)
> /// klist(20 33) weight(equal) /// lframe(myresults, replace) /// svy
> over(area region) /// cotmeasures(all) cotframe(mycot, replace)
> tvar(t) cotyear(year)

Here below, we compare the results from the Stata package and this
version in R. We merged both data frames with the results (point
estimate, standard errors, and confidence intervals). We calculate the
L1 distance between the estimates ($|\theta_{R}-\theta_{Stata}|$) by
measure in the case of the “lframe” results and by ctype and annualized
measure in the case of the “cotframe” results.

The following output shows the summary of the distribution of this
comparisons (suffix “.x” refers to the estimates of the R package and
“.y” to the Stata version).

``` r
# "lframe" COMPARISONS
aggregate(abs(b.x - b.y)~ measure, merged, summary)
aggregate(abs(se.x - se.y)~ measure, merged, summary)
aggregate(abs(ll.x - ll.y)~ measure, merged, summary)
aggregate(abs(ul.x - ul.y)~ measure, merged, summary)
# "cotframe" COMPARISONS
aggregate(abs(b.x - b.y)~ ctype+ann, cot.merged, summary)
aggregate(abs(se.x - se.y)~ ctype+ann, cot.merged, summary)
aggregate(abs(ll.x - ll.y)~ ctype+ann, cot.merged, summary)
aggregate(abs(ul.x - ul.y)~ ctype+ann, cot.merged, summary)
```

All the results are very close with some exceptions found in few
estimates of the standard errors of the relative changes over time
measures. Since the point estimates (“b”) are close and Delta method is
used for calculating the standard errors, here there may be some
differences between the “survey” library in R and Stata

------------------------------------------------------------------------
