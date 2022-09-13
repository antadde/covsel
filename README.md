
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covsel

The goal of *covsel* is to streamline the main steps of our
newly-devised covariate selection procedure aimed at optimizing the
predictive abilities and parsimony of ensemble species distribution
models fitted in a context of high dimensional candidate covariate
space. Our covariate selection procedure is developed around three main
algorithms: Generalized Linear Model (GLM), Generalized Additive Model
(GAM), and Random Forest (RF). It is made of two main steps: (Step A)
“Collinearity filtering”, and (Step B) “Model-specific embedding” . More
details to come in the companion paper by Adde et al. (in prep).

### Installation

You can install the development version of *covsel* from
[GitHub](https://github.com/) with:

``` r
if(!"covsel" %in% installed.packages()) devtools::install_github("N-SDM/covsel", auth_token = "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")
```

## Package functionality

*covsel* includes a set of three functions used to streamline
covariate selection. These functions are:

| Function name         | Function description                                                                                                         |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------|
| `covsel.filteralgo()` | Colinearity filtering                                                                                                        |
| `covsel.embed()`      | Model-specific embedding                                                                                                     |
| `covsel.filter()`     | Apply the colinearity filtering algorithm at each target level (e.g. variable level; ii=category level; iii= all remainders) |

# Example

### Introduction

This example illustrates the functions of the *covsel* package by using
occurrence data for the alpine marmot (*Marmota marmota) –* in
Switzerland and a suite of 75 environmental covariates from 8 categories
(bioclimatic, land use and cover, edaphic, hydrologic, human population,
transportation, vegetation, and topographic) that are candidates for
modelling its potential distribution. The aim is to reduce the
dimensionality of the covariate set and select the top 12 covariates to
be used in the final model.

``` r
library(covsel)
```

### Load data

The *data_covsel* dataset attached to this package contains a `list` of
three objects including (i) `data_covsel$pa` a vector of presences (1)
and absences (0), (ii) `data_covsel$env_vars` a data.frame containing
the covariate data, and (iii) `data_covsel$catvar` a look-up data.frame
containing `data_covsel$catvar$variable`, the variable-level
names`and`data_covsel*c**a**t**v**a**r*category\` and category-level
names of each covariate, both of length=ncol(covdata). Information on
variable names and categories will be useful for applying the
colinearity filtering algorithm in a stratified way (e.g.: variable
level first, then category level, then all remainders).

``` r
table(data_covsel$pa) # 3,609 presences and 10,000 background absences
#> 
#>     0     1 
#> 10000  3609
dim(data_covsel$env_vars) # 75 candidate environmental covariates extracted at each of the 3,609 + 10,000 points
#> [1] 13609    75
```

### Covariate selection

The selection procedure is made of two steps: (Step A) “Collinearity
filtering”, and (Step B) “Model-specific embedding”.

#### Step A: colinearity filtering

In Step A, we reduce the dimensionality of the candidate set by
eliminating the less informative covariates among collinear pairs, based
on correlation matrices and univariate GLM p-values. The colinearity
filtering algorithm can be either run on the whole set of candidate
covariates, or in a stratified (e.g.: variable level, category level,
all remainders).

##### whole set

For running the colinearity filtering algorithm on the whole candidate
covariate set, directly use the `covsel.filteralgo` function. Here we
are using a threshold value `corcut` of \|r\| \< 0.70 (default) for
identifying colinear pairs. It is possible to assign weights to each
element in the `pa` vector and the argument `force` can be used to
specify a character vector indicating the name(s) of the covariate(s) to
be forced in the final set. See help(covsel.filteralgo) for details.

``` r
covdata<-data_covsel$env_vars
pa<-data_covsel$pa
dim(covdata) # 75 candidates before colinearity filtering
#> [1] 13609    75
covdata_filter<-covsel.filteralgo(covdata=covdata, pa=pa, corcut=0.7)
dim(covdata_filter) # much less after
#> [1] 13609    45
```

##### stratified

For running the colinearity filtering algorithm in a stratified way
(e.g.: variable level first, then category level, then all remainders),
use the wrapper function `covsel.filter` function. In addition to the
argument described above, this function needs at least (or both)
information on the variable-level or/and category-level names. These can
be provided as character vectors of length=ncol(covdata) to the
arguments `variables` and `weights`.

``` r
covdata<-data_covsel$env_vars
pa<-data_covsel$pa
dim(covdata) # 75 candidates before colinearity filtering
#> [1] 13609    75
covdata_filter<-covsel.filter(covdata=covdata, pa=pa, corcut=0.7, variables=data_covsel$catvar$variable, categories=data_covsel$catvar$category)
dim(covdata_filter) # much less after
#> [1] 13609    37
```

#### Step B: model-specific embedding

Selected covariates from step A are used to fit models with embedded
selection procedures by using the `covsel.embed` function. Available
algorithms are: GLM with elastic-net regularization, GAM with null-space
penalization, and guided regularized RF. They can be used together
(default) or individually by tuning the `algorithms` argument. For each
algorithm, the n covariates retained after regularization are ranked
from 1 (“best”) to n (“worst”). The algorithm-specific ranking is done
based on the absolute value of the regularized regression coefficients
for GLM, the chi-square statistic for GAM, and the Mean Decrease Gini
index for RF, all to be maximized. The final overall ranking is obtained
by ordering the sum of the three ranks for each covariate, starting with
the covariates that were commonly selected by all the algorithms, and
then adding the remaining. The top ncov covariates are selected as the
final modelling set, with `ncov` and `maxncov` being user-specifiable
arguments with default values round(log2(number of occurrences)) and 12,
respectively. See help(covsel.embed) for details on all other arguments
(`weights`, `force`, `nthreads`, etc.).

``` r
covdata<-data_covfilter
pa<-data_covsel$pa
dim(covdata) # 37 candidates before embedding
#> [1] 13609    37
covdata_embed<-covsel.embed(covdata=covdata, pa=pa, algorithms=c('glm','gam','rf'), ncov=ceiling(log2(length(which(pa==1)))), maxncov=12) # takes some time
dim(covdata_embed$covdata) # top 12 retained for the final modelling set
#> [1] 13609    12
print(covdata_embed$ranks_2) # ranking table
#>                                             covariate      rank rank.f
#> 1                     ch_bioclim_chclim25_pixel_bio11  1.333333      1
#> 9              ch_transport_tlm3d_pixel_dist2road_all  1.666667      2
#> 6    ch_lulc_geostat2_present_pixel_2013_2018_cl1_100  3.000000      3
#> 4                      ch_bioclim_chclim25_pixel_bio4  5.666667      4
#> 8                 ch_topo_alti3d2016_pixel_slope_mean  5.666667      5
#> 7  ch_lulc_geostat65_present_pixel_2013_2018_cl46_100  6.666667      6
#> 5                     ch_edaphic_eivdescombes_pixel_w  8.000000      7
#> 2                     ch_bioclim_chclim25_pixel_bio15  8.666667      8
#> 3                      ch_bioclim_chclim25_pixel_bio3 11.666667      9
#> 71   ch_lulc_geostat2_present_pixel_2013_2018_cl2_100  6.000000     10
#> 31                    ch_edaphic_eivdescombes_pixel_f  9.500000     11
#> 27             ch_vege_copernicus_pixel_deciduous_100 11.500000     12
```

# Contributing

If you have a suggestion that would make *covsel* better, please fork
the repository and create a pull request. You can also simply open an
issue with the tag “enhancement”. Thanks!

# Citation

To cite *covsel* or acknowledge its use, cite us as follows,
substituting the version of *covsel* that you used for “version 1.0”:

\[info hidden for peer review\] et al. 2022. Too many candidates:
embedded covariate selection procedure for ensemble species distribution
modelling. – XXX XXX: XXX (ver. 1.0).

# Contact

\[info hidden for peer review\]

Project Link: <https://github.com/N-SDM/covsel>

# Acknowledgments

*covsel* development has been conducted within the \[info hidden for
peer review\] lab <https://www.unil.ch/ecospat/en/home.html>.

We gratefully acknowledge financial support through the Action Plan of
the Swiss Biodiversity Strategy by the Federal Office for the
Environment (FOEN) for financing the Valpar.ch and SwissCatchment
projects.

The Swiss Species Information Center InfoSpecies (www.infospecies.ch)
supplied Swiss-level species occurrence data and expertise on species’
ecology, and we acknowledge their support regarding the database.

This research was enabled in part by the support provided by the
Scientific Computing and Research Unit of Lausanne University
(<https://www.unil.ch/ci/dcsr>).
