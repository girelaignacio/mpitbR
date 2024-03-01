mpitb.cot.M0 <- function(k, data, over,
                         tvar, cotyear,
                         level){
  # poverty cutoff as decimal
  k <- k/100
  # calculate censored deprivation score and add to the dataset
  censored_c.score <- censored_c.score(data$variables$c.score, k)
  data <- update.svy(data, y = censored_c.score)

  # define the vector of the subgroups
  # define the expression for the formula
  bys <- paste(over, tvar, sep= "+")

  # calculate the adjusted headcount ratio
  # if it is used Linux OS, it uses fork to parallelize calculations by loa
  # (if (multicore) parallel::mclapply else lapply)
  # calculate the estimated measures with svymean because svyciprop do not yield
  # the covariance for delta method!
  M0 <- lapply(bys, function(by) survey::svyby(survey::make.formula("y"),
                    by=survey::make.formula(by),
                    design=data, survey::svymean, covmat = TRUE, na.rm=FALSE))
  M0 <- lapply(M0, function(x) {attr(x,"measure") <- "M0"; x})
  M0 <- lapply(M0, function(x) {attr(x,"k") <- k*100; x})
  return(M0)
}
