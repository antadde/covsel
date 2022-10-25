context("covsel.filteralgo")
library(covsel)

# Run example from covsel #
covdata<-data_covsel$env_vars
covdata_filter<-covsel.filteralgo(covdata, pa=data_covsel$pa)

# Test section #
test_that("object class is correct", {
  expect_type(covdata_filter, "list")
})

test_that("covariate set was reduced", {
  expect_true(ncol(covdata_filter) < ncol(covdata))
})