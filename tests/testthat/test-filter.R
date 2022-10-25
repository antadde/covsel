context("covsel.filter")
library(covsel)

# Run example from covsel #
covdata<-data_covsel$env_vars
covdata_filter<-covsel.filter(covdata,
                              pa=data_covsel$pa,
                              variables=data_covsel$catvar$variable,
                              categories=data_covsel$catvar$category)
# Test section #
test_that("object class is correct", {
  expect_type(covdata_filter, "list")
})

test_that("covariate set was reduced", {
  expect_true(ncol(covdata_filter) < ncol(covdata))
})