
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
# The package is not available on CRAN for the moment, you can install it from GitHub!
if (!require("mpitbR", character.only = TRUE)) {
  devtools::install_github("girelaignacio/mpitbR")
}
#> Loading required package: mpitbR
```

This process may take time the first time.

## A short example

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
system.time(
est <- mpitb.est(set, c(20, 33), over = c("area","region"), 
                 tvar = "t", cotyear = "year")
)             
#>         ****** SPECIFICATION ******
#> Call:
#> mpitb.est.mpitb_set(set = set, klist = c(20, 33), over = c("area", 
#>     "region"), cotyear = "year", tvar = "t")
#> Name:  myname 
#> Weighting scheme:  equal 
#> Description:  pref. desc 
#> ___________________
#>                                                                      
#> Dimension 1:  d1 0.333                                 (d_nutr, d_cm)
#> Dimension 2:  d2 0.333                               (d_satt, d_educ)
#> Dimension 3:  d3 0.333 (d_elct, d_sani, d_wtr, d_hsg, d_ckfl, d_asst)
#> ___________________
#>                             
#> Indicator 1:   d_nutr 0.1667
#> Indicator 2:     d_cm 0.1667
#> Indicator 3:   d_satt 0.1667
#> Indicator 4:   d_educ 0.1667
#> Indicator 5:   d_elct 0.0556
#> Indicator 6:   d_sani 0.0556
#> Indicator 7:    d_wtr 0.0556
#> Indicator 8:    d_hsg 0.0556
#> Indicator 9:   d_ckfl 0.0556
#> Indicator 10:  d_asst 0.0556
#> 
#>         ****** ESTIMATION ******
#> ___________________
#> Partial AF measures: ' M0 H A ' under estimation... DONE
#> 
#> ___________________
#> Indicator-specific measures: ' hd hdk actb pctb ' under estimation... DONE
#> 
#> ___________________
#> Estimate changes over time over ' M0 H A hd hdk ' measures... DONE
#> 
#>         ****** RESULTS ******
#> ___________________
#> Parameters
#> Number of time periods:  2 
#> Subgroups:  3 
#> Poverty cut-offs (k):  2 
#> 
#> *Notes: 
#>   Confidence level: 95 %
#>   Parallel estimations:  FALSE
#>    user  system elapsed 
#>   26.53    0.62   97.25
```

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
#>   measure abs(b.x - b.y).Min. abs(b.x - b.y).1st Qu. abs(b.x - b.y).Median
#> 1       A        2.537193e-10           2.496580e-09          6.505966e-09
#> 2    actb        2.573115e-14           6.975318e-11          1.892713e-10
#> 3       H        1.972034e-13           3.192835e-09          9.451868e-09
#> 4     hdk        2.442491e-15           1.071102e-09          2.483521e-09
#> 5      M0        1.436365e-11           1.280760e-09          2.683751e-09
#> 6    pctb        2.979159e-12           7.875736e-10          1.820007e-09
#>   abs(b.x - b.y).Mean abs(b.x - b.y).3rd Qu. abs(b.x - b.y).Max.
#> 1        8.427761e-09           1.304837e-08        2.210272e-08
#> 2        4.151699e-10           4.673255e-10        3.131624e-09
#> 3        1.100592e-08           1.678608e-08        2.963083e-08
#> 4        3.248355e-09           4.859661e-09        1.471275e-08
#> 5        3.275439e-09           4.787983e-09        1.169818e-08
#> 6        3.267782e-09           3.926226e-09        2.626389e-08
aggregate(abs(se.x - se.y)~ measure, merged, summary)
#>   measure abs(se.x - se.y).Min. abs(se.x - se.y).1st Qu.
#> 1       A          5.416848e-13             5.584464e-11
#> 2       H          1.160892e-11             1.849522e-10
#> 3     hdk          5.614433e-15             1.316371e-10
#> 4      M0          1.465078e-13             6.681607e-11
#>   abs(se.x - se.y).Median abs(se.x - se.y).Mean abs(se.x - se.y).3rd Qu.
#> 1            1.480838e-10          1.902079e-10             2.567154e-10
#> 2            4.395547e-10          4.371655e-10             6.625546e-10
#> 3            2.777703e-10          3.432593e-10             4.983902e-10
#> 4            1.752028e-10          2.275738e-10             3.695835e-10
#>   abs(se.x - se.y).Max.
#> 1          6.804142e-10
#> 2          1.160708e-09
#> 3          1.832390e-09
#> 4          6.184998e-10
aggregate(abs(ll.x - ll.y)~ measure, merged, summary)
#>   measure abs(ll.x - ll.y).Min. abs(ll.x - ll.y).1st Qu.
#> 1       A          2.891913e-10             4.516447e-09
#> 2       H          3.786096e-11             3.067251e-09
#> 3     hdk          2.370888e-12             8.662990e-10
#> 4      M0          3.895412e-12             1.577318e-09
#>   abs(ll.x - ll.y).Median abs(ll.x - ll.y).Mean abs(ll.x - ll.y).3rd Qu.
#> 1            7.651098e-09          9.340626e-09             1.471136e-08
#> 2            7.146682e-09          9.442070e-09             1.297974e-08
#> 3            1.933710e-09          2.616787e-09             3.715519e-09
#> 4            2.832272e-09          3.768499e-09             5.334923e-09
#>   abs(ll.x - ll.y).Max.
#> 1          2.192765e-08
#> 2          2.958044e-08
#> 3          1.457998e-08
#> 4          1.119702e-08
aggregate(abs(ul.x - ul.y)~ measure, merged, summary)
#>   measure abs(ul.x - ul.y).Min. abs(ul.x - ul.y).1st Qu.
#> 1       A          1.068123e-10             3.338948e-09
#> 2       H          2.997895e-10             3.667333e-09
#> 3     hdk          2.556844e-12             1.451214e-09
#> 4      M0          4.180370e-11             1.734692e-09
#>   abs(ul.x - ul.y).Median abs(ul.x - ul.y).Mean abs(ul.x - ul.y).3rd Qu.
#> 1            9.316736e-09          1.024661e-08             1.643490e-08
#> 2            7.834429e-09          9.890734e-09             1.367126e-08
#> 3            3.231405e-09          4.022657e-09             5.815440e-09
#> 4            2.776975e-09          3.904529e-09             5.206159e-09
#>   abs(ul.x - ul.y).Max.
#> 1          2.196234e-08
#> 2          2.897404e-08
#> 3          1.487718e-08
#> 4          1.141741e-08
# "cotframe" COMPARISONS
aggregate(abs(b.x - b.y)~ ctype+ann, cot.merged, summary)
#>   ctype ann abs(b.x - b.y).Min. abs(b.x - b.y).1st Qu. abs(b.x - b.y).Median
#> 1   abs   0        1.870067e-12           3.986193e-10          9.686187e-10
#> 2   rel   0        0.000000e+00           2.259034e-07          5.014027e-07
#> 3   abs   1        1.213274e-13           4.091187e-11          1.063642e-10
#> 4   rel   1        6.494183e-11           2.966984e-08          6.917366e-08
#>   abs(b.x - b.y).Mean abs(b.x - b.y).3rd Qu. abs(b.x - b.y).Max.
#> 1        1.306578e-09           1.800450e-09        7.372153e-09
#> 2        6.315608e-07           9.005053e-07        3.124419e-06
#> 3        1.466689e-10           2.025327e-10        9.089043e-10
#> 4        9.569769e-08           1.382636e-07        4.512245e-07
aggregate(abs(se.x - se.y)~ ctype+ann, cot.merged, summary)
#>   ctype ann abs(se.x - se.y).Min. abs(se.x - se.y).1st Qu.
#> 1   abs   0          1.005595e-12             1.454863e-10
#> 2   rel   0          1.336629e-10             7.273540e-08
#> 3   abs   1          9.507152e-14             1.883742e-11
#> 4   rel   1          6.217767e-03             2.716328e-01
#>   abs(se.x - se.y).Median abs(se.x - se.y).Mean abs(se.x - se.y).3rd Qu.
#> 1            3.474039e-10          4.443008e-10             6.531834e-10
#> 2            1.756040e-07          2.289277e-07             3.466214e-07
#> 3            4.398334e-11          5.422530e-11             7.891720e-11
#> 4            5.626021e-01          6.760697e-01             9.482485e-01
#>   abs(se.x - se.y).Max.
#> 1          1.851897e-09
#> 2          1.531625e-06
#> 3          2.298776e-10
#> 4          2.765468e+00
aggregate(abs(ll.x - ll.y)~ ctype+ann, cot.merged, summary)
#>   ctype ann abs(ll.x - ll.y).Min. abs(ll.x - ll.y).1st Qu.
#> 1   abs   0          1.346874e-11             7.850920e-10
#> 2   rel   0          2.511535e-03             2.485258e-02
#> 3   abs   1          3.490333e-13             8.488581e-11
#> 4   rel   1          1.146200e-02             5.351600e-01
#>   abs(ll.x - ll.y).Median abs(ll.x - ll.y).Mean abs(ll.x - ll.y).3rd Qu.
#> 1            1.736229e-09          2.128073e-09             3.047644e-09
#> 2            4.081943e-02          4.167009e-02             5.212143e-02
#> 3            2.046016e-10          2.507769e-10             3.609115e-10
#> 4            1.110923e+00          1.332081e+00             1.866285e+00
#>   abs(ll.x - ll.y).Max.
#> 1          7.358144e-09
#> 2          1.942154e-01
#> 3          9.300637e-10
#> 4          5.443221e+00
aggregate(abs(ul.x - ul.y)~ ctype+ann, cot.merged, summary)
#>   ctype ann abs(ul.x - ul.y).Min. abs(ul.x - ul.y).1st Qu.
#> 1   abs   0          9.180157e-15             1.488304e-10
#> 2   rel   0          2.511125e-03             2.485225e-02
#> 3   abs   1          1.191148e-14             1.592135e-11
#> 4   rel   1          1.146202e-02             5.351599e-01
#>   abs(ul.x - ul.y).Median abs(ul.x - ul.y).Mean abs(ul.x - ul.y).3rd Qu.
#> 1            3.799376e-10          5.828455e-10             8.125335e-10
#> 2            4.081976e-02          4.167006e-02             5.212298e-02
#> 3            5.067517e-11          7.176588e-11             1.026436e-10
#> 4            1.110923e+00          1.332081e+00             1.866285e+00
#>   abs(ul.x - ul.y).Max.
#> 1          3.657657e-09
#> 2          1.942111e-01
#> 3          4.391873e-10
#> 4          5.443222e+00
```

All the results are very close with some exceptions found in few
estimates of the standard errors of the relative changes over time
measures. Since the point estimates (“b”) are close and Delta method is
used for calculating the standard errors, here there may be some
differences between the “survey” library in R and Stata

------------------------------------------------------------------------
