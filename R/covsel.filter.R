#' covsel.filter
#'
#' Apply the colinearity filtering algorithm at each target level (i=variable level; ii=category level; iii= all remainders)
#'
#' @param pa vector of species presences (1) and absences (0)
#' @param covdata data.frame containing covariate data
#' @param variables character vector of length ncol(covdata) containing variable-level names
#' @param categories character vector of length ncol(covdata) containing category-level names
#' @param weights vector containing the weights for each value in 'pa' (of length 'pa')
#' @param force optional character vector indicating the name(s) of the covariate(s) to be forced in the final set
#' @param corcut The value (numeric) of the correlation coefficient threshold for identifying colinearity
#'
#' @return A data.frame of "non-colinear" candidate covariates
#' @author Antoine Adde (antoine.adde@unil.ch)
#' @examples
#' covdata<-data_covsel$env_vars
#' dim(covdata)
#' covdata_filter<-covsel.filter(covdata,
#'                               pa=data_covsel$pa,
#'                               variables=data_covsel$catvar$variable,
#'                               categories=data_covsel$catvar$category)
#' dim(covdata_filter)
#' @export

covsel.filter <- function(covdata, pa, variables=NULL, categories=NULL, weights=NULL, force=NULL, corcut=0.7){
# i-variable level (if available, select one covariate per variable)
if(length(variables)>0){
covdata.candidates <- split.default(covdata, variables)
covdata.variable.filter<-lapply(covdata.candidates, covsel.filteralgo, pa=pa, weights=weights, force=force, corcut=0)
covdata<-do.call("cbind", covdata.variable.filter)
names(covdata)<-gsub("^.*\\.","", names(covdata))
if(length(categories)>0) categories<-categories[match(names(covdata.variable.filter), variables)]
}

# ii-category level (if available, filtering conducted per category)
if(length(categories)>0){
covdata.candidates <- split.default(covdata, categories)
covdata.category.filter<-lapply(covdata.candidates, covsel.filteralgo, pa=pa, weights=weights, force=force, corcut=corcut)
covdata<-do.call("cbind", covdata.category.filter)
names(covdata)<-gsub("^.*\\.","", names(covdata))
}

# iii-all remainders
covdata.filter<-covsel.filteralgo(covdata, pa, weights=weights, force=force, corcut=corcut)
names(covdata.filter)<-gsub("^.*\\.","", names(covdata.filter))

# return results
return(covdata.filter)
}


