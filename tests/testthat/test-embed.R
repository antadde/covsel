context("covsel.embed")
library(covsel)

# Run example from covsel #
covdata<-data_covfilter
covdata_embed<-covsel.embed(covdata, pa=data_covsel$pa, algorithms=c('glm','gam','rf'))

# Test section #
test_that("object class is correct", {
  expect_type(covdata_embed, "list")
  expect_type(covdata_embed$ranks_1, "list")
  expect_type(covdata_embed$ranks_2, "list")
  expect_type(covdata_embed$covdata, "list")

})

test_that("covariate set was reduced", {
  expect_true(ncol(covdata_embed$covdata) < ncol(covdata))
})