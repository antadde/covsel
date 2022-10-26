
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![Codecov test coverage](https://codecov.io/gh/N-SDM/covsel/branch/main/graph/badge.svg)](https://app.codecov.io/gh/N-SDM/covsel?branch=main)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/N-SDM/covsel?branch=main&svg=true)](https://ci.appveyor.com/project/N-SDM/covsel)
[![DOI](https://zenodo.org/badge/534570422.svg)](https://zenodo.org/badge/latestdoi/534570422)
<!-- badges: end -->
  
# covsel

The *covsel* R package is a ready-to-use, automated, covariate selection
tool for species distribution modelling. It implements and streamlines
the two steps of our novel “embedded” covariate selection procedure that
combines (Step A) a collinearity-filtering algorithm and (Step B) three
model-specific embedded regularization techniques, including generalized
linear model with elastic net regularization, generalized additive model
with null-space penalization, and guided regularized random forest. More
details will come in the companion paper by \[hidden for peer-review\]
(in prep).

### Installation

The *covsel* package requires a standard installation of R
(version≥4.0.0). You can install the development version of *covsel*
from GitHub:

``` r
if(!"covsel" %in% installed.packages()) devtools::install_github("N-SDM/covsel")
```

## Package functionalities

The current version of the *covsel* package (ver. 1.0) includes a set of
three functions. See function help files for additional details on input
data, arguments, and examples.

| Function name         | Function description                                                                                                                                     |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| `covsel.filteralgo()` | Collinearity filtering (Step A)                                                                                                                          |
| `covsel.embed()`      | Model-specific embedding (Step B)                                                                                                                        |
| `covsel.filter()`     | Wrapper function applying the collinearity filtering algorithm at each target level(s) (e.g. i: variable level; ii: category level; iii: all remainders) |

# Example

### Introduction

This example illustrates the functionalities of the *covsel* package.
The goal is to model the habitat suitability of the alpine marmot
(*Marmota marmota*) in Switzerland, starting with a suite of 75
candidate covariates derived from 8 main categories (bioclimatic, land
use and cover, edaphic, hydrologic, human population, transportation,
vegetation, and topographic). Our aim is to reduce the dimensionality of
the covariate set and select the top 12 covariates that will be used in
the final model.

``` r
library(covsel)
```

### Load data

The *data_covsel* dataset attached to the *covsel* package contains a
`list` of three objects: (i) `data_covsel$pa` a numeric vector of
presences ‘1’ and absences ‘0’, (ii) `data_covsel$env_vars` a data frame
containing covariate data extracted at `pa` locations, and (iii)
`data_covsel$catvar` a two columns look-up data frame
`data_covsel$catvar$variable` and `data_covsel$catvar$category`, the
variable-level names and category-level names of each covariate,
respectively. Information on variable- and category-level covariate
names will be useful for applying the collinearity filtering algorithm
in a stratified way (e.g.: variable level first, then category level,
then all remainders).

``` r
table(data_covsel$pa) # 3,609 presences and 10,000 background absences
#> 
#>     0     1 
#> 10000  3609
dim(data_covsel$env_vars) # 75 candidate environmental covariates extracted at pa locations
#> [1] 13609    75
```

### Covariate selection

The selection procedure is made of two main steps: (Step A)
“Collinearity filtering”, and (Step B) “Model-specific embedding”.

#### Step A: Collinearity filtering

In Step A, we reduce the dimensionality of the candidate covariate set
by eliminating the less informative covariates among collinear pairs.
This is done by iteratively reducing a correlation matrix in which the
covariates are ordered based on univariate GLM p-values. Collinear
covariate pairs are identified using the Pearson correlation coefficient
\|r\| threshold corcut, with corcut \> 0.70 as default value. For
maximizing the diversity of selected covariates, the filtering step can
be sequentially applied at three levels: (i) the variable (e.g.,
selecting the best covariate for the “proportion of forest” variable
calculated in 100-m, 500-m, or 1-km radii), (ii) the category (e.g.:
within the “bioclimatic”, “edaphic”, or “hydrologic” categories), and
(iii) using all remainders.

In this example, will run the collinearity filtering algorithm (i) first
directly on the whole set of candidate covariates, (ii) then in a
sequential way (variable level first, then category level, then all
remainders).

##### directly on the whole set

For running the collinearity filtering algorithm on the whole candidate
covariate set, we directly use the `covsel.filteralgo` function. Here we
are using the default `corcut` value \|r\| \< 0.70 for identifying
collinear pairs. It is possible to assign weights to each element in the
`pa` vector and the argument `force` can be used to specify a character
vector indicating the name(s) of the covariate(s) to be forced in the
final set. See help(`covsel.filteralgo`) for details.

``` r
covdata<-data_covsel$env_vars
pa<-data_covsel$pa
dim(covdata) # 75 candidates before collinearity filtering
#> [1] 13609    75
covdata_filter<-covsel.filteralgo(covdata=covdata,
                                  pa=pa,
                                  corcut=0.7) # default value
dim(covdata_filter) # much less after
#> [1] 13609    45
```

##### in a sequential way

For running the collinearity filtering algorithm in a sequential way
(e.g.: variable level first, then category level, then all remainders),
we will use the wrapper function `covsel.filter`. In addition to the
arguments described for `covsel.filteralgo`, this function requires
information on the variable-level or/and category-level covariate names.
These can be provided as character vectors to the arguments `variables`
and `categories`, respectively.

``` r
covdata<-data_covsel$env_vars
pa<-data_covsel$pa
dim(covdata) # 75 candidates before collinearity filtering
#> [1] 13609    75
covdata_filter<-covsel.filter(covdata=covdata,
                              pa=pa,
                              corcut=0.7, # default value
                              variables=data_covsel$catvar$variable,
                              categories=data_covsel$catvar$category)
dim(covdata_filter) # much less after
#> [1] 13609    37
```

#### Step B: Model-specific embedding

Covariates selected after step A are used to fit models with embedded
selection procedures using the `covsel.embed` function. Available
algorithms in the current version of the *covsel* package (ver. 1.0)
are: GLM with elastic-net regularization, GAM with null-space
penalization, and guided regularized RF. They can be used together
(default), or individually by tuning the `algorithms` argument. For each
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
respectively. See help(`covsel.embed`) for details on other optional
arguments (i.e. `weights`, `force`, `nthreads`, etc.).

``` r
covdata<-data_covfilter
pa<-data_covsel$pa
dim(covdata) # 37 candidates before embedding
#> [1] 13609    37
covdata_embed<-covsel.embed(covdata=covdata,
                            pa=pa,
                            algorithms=c('glm','gam','rf'), # default value
                            ncov=ceiling(log2(length(which(pa==1)))), # default value
                            maxncov=12, # default value
                            nthreads=detectCores()/2)  # default value
```

Here we are! Below is the list of the top 12 covariates retained for
modelling the habitat suitability of the alpine marmot (*Marmota
marmota*) in Switzerland.

``` r
dim(covdata_embed$covdata) # data.frame with the top 12 retained for the final modelling set
#> [1] 13609    12
print(covdata_embed$ranks_2) # ranking table
#>                                              covariate rank.f
#> 1                      ch_bioclim_chclim25_pixel_bio11      1
#> 9               ch_transport_tlm3d_pixel_dist2road_all      2
#> 6     ch_lulc_geostat2_present_pixel_2013_2018_cl1_100      3
#> 4                       ch_bioclim_chclim25_pixel_bio4      4
#> 7   ch_lulc_geostat65_present_pixel_2013_2018_cl46_100      5
#> 8                  ch_topo_alti3d2016_pixel_slope_mean      6
#> 5                      ch_edaphic_eivdescombes_pixel_w      7
#> 2                      ch_bioclim_chclim25_pixel_bio13      8
#> 3                       ch_bioclim_chclim25_pixel_bio3      9
#> 71    ch_lulc_geostat2_present_pixel_2013_2018_cl2_100     10
#> 14  ch_lulc_geostat65_present_pixel_2013_2018_cl37_100     11
#> 110                    ch_bioclim_chclim25_pixel_bio15     12
```

# Contributing

If you have a suggestion that would make *covsel* better, please fork
the repository and create a pull request. You can also simply open an
issue with the tag “enhancement”. Thanks!

# Citation

To cite *covsel* or acknowledge its use, cite the package as follows,
substituting the version of *covsel* that you used for “version 1.0”:

\[info hidden for peer review\] et al. 2022. Too many candidates:
embedded covariate selection procedure for species distribution
modelling with the covsel R package. – XXX XXX: XXX (ver. 1.0).

# Contact

\[info hidden for peer review\]

Project Link: <https://github.com/N-SDM/covsel>

# Acknowledgments

*covsel* development has been conducted within the \[info hidden for
peer review\] lab

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
