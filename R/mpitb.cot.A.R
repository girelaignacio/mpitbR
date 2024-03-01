mpitb.cot.A_svyciprop <- function(k, data, over,
                        tvar, cotyear,
                        level){
  # poverty cutoff as decimal
  k <- k/100
  # calculate censored deprivation score and add to the dataset
  censored_c.score <- censored_c.score(data$variables$c.score, k)
  # calculate censored deprivation score and add to the dataset
  poor.mpi <- ifelse(data$variables$c.score >= k,1,0)
  data <- update.svy(data, y = censored_c.score, mpi.k = poor.mpi)

  # define the vector of the subgroups
  # define the expression for the formula
  bys <- paste(over, tvar, sep= "+")

  # calculate the adjusted headcount ratio
  # if it is used Linux OS, it uses fork to parallelize calculations by loa
  # (if (multicore) parallel::mclapply else lapply)
  # calculate the estimated measures with svymean because svyciprop do not yield
  # the covariance for delta method!
  A <- lapply(bys, function(by) survey::svyby(survey::make.formula("y"),
                                              by=survey::make.formula(by),
                                              design=subset(data, data$variables[,'mpi.k']==1), survey::svymean, covmat = TRUE, na.rm=FALSE))
  A <- lapply(A, function(x) {attr(x,"measure") <- "A"; x})
  A <- lapply(A, function(x) {attr(x,"k") <- k*100; x})
  return(A)
}
