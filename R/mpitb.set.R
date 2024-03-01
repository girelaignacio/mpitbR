#' Set the specification of the Multidimensional Poverty Measurement and Analysis project
#'
#' @param data a \code{survey.design}-class object where a complex survey design was previously specified. Can be a matrix but it is coerced to a `survey.design` class assuming equal probabilities.
#' @param indicators a list or character vector containing the names of the indicators. If it is a list, the element represents the dimension which character vector with their corresponding indicators. At most 10 dimensions are allowed. The indicators should belong to columns names of `data`.
#' @param name a character containing a desired specification of the project name. It also serves as an ID and it is recommended to use short names (at most 10 characters are permitted).
#' @param desc a character containing a desired specification of the project description.
#' @param ... other arguments
#'
#' @return \code{mpitb_set}-class object
#'
#' @export

mpitb.set <- function(data, indicators, ..., name = "unnamed", desc = "desc."){

  ####################
  #### Catch call ####
  ####################
  this.call <- match.call()
  # Print this call so that the user can check if arguments are correctly assigned
  print(this.call)
  # Save this.call as list for do.call(".check_mpitb.est", `list`)
  this.call$... <- NULL
  list.args <- as.list(this.call)

  ##########################
  #### Check arguments ####
  #########################

  Args <- do.call(".checkArgs_set", list.args)

  ## Get the checked arguments
  data = Args$data
  indicators = Args$indicators
  name = Args$name
  desc = Args$desc

  ################
  #### RETURN ####
  ################

  SET <- list()

  SET$data <- data

  SET$indicators <- indicators

  attr(SET,"name") <- name

  attr(SET,"desc") <- desc

  class(SET) <- "mpitb_set"

  return(SET)
}
