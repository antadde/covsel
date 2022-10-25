context("covsel.filteralgo")
library(covsel)

# Run example from covsel #
covdata<-data_covsel$env_vars
covdata_filter<-covsel.filteralgo(covdata, pa=data_covsel$pa, force="ch_bioclim_chclim25_pixel_bio11")

# Test section #
test_that("object class is correct", {
  expect_type(covdata_filter, "list")
})

test_that("covariate set was reduced", {
  expect_true(ncol(covdata_filter) < ncol(covdata))
})

test_that("ch_bioclim_chclim25_pixel_bio11 is forced in the final set", {
  expect_true("ch_bioclim_chclim25_pixel_bio11" %in% colnames(covdata_filter))
})