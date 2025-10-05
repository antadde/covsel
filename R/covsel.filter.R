#' covsel.filter
#'
#' Apply the collinearity filtering algorithm at each target level (i=variable level; ii=category level; iii= all remainders)
#'
#' @param covdata A data.frame containing continuous covariate values extracted at presence–absence ('pa') locations.
#' @param pa A numeric vector indicating species presences (1) and absences (0).
#' @param weights A numeric vector of weights corresponding to each value in 'pa' (same length as 'pa').
#' @param force An optional character vector specifying the name(s) of covariate(s) to be forced into the final set.
#' @param corcut A numeric value specifying the correlation coefficient threshold used to identify collinearity.
#' @param variables A character vector of length equal to ncol(covdata) containing variable-level information.
#' @param categories A character vector of length equal to ncol(covdata) containing category-level information.
#'
#' @return A data.frame containing the set of non-collinear candidate covariates.
#' @author Antoine Adde (antoine.adde@eawag.ch)
#' @examples
#' library(covsel)
#' covdata<-data_covsel$env_vars
#' dim(covdata)
#' covdata_filter<-covsel.filter(covdata,
#'                               pa=data_covsel$pa,
#'                               variables=data_covsel$catvar$variable,
#'                               categories=data_covsel$catvar$category)
#' dim(covdata_filter)
#' @export

covsel.filter <- function(covdata, pa, weights=NULL, force=NULL, corcut=0.7, variables=NULL, categories=NULL){
# i-variable level (if available, filtering per variable)
if(length(variables)>0){
covdata.candidates <- split.default(covdata, variables)
covdata.variable.filter<-lapply(covdata.candidates, covsel.filteralgo, pa=pa, weights=weights, force=force, corcut=0) # corcut=0 select one covariate per variable
covdata<-do.call("cbind", covdata.variable.filter)
names(covdata)<-gsub("^.*\\.","", names(covdata))
if(length(categories)>0) categories<-categories[match(names(covdata.variable.filter), variables)]
}

# ii-category level (if available, filtering per category)
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


