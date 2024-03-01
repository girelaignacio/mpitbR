mpitb.est <- function(set, klist = NULL, weights = NULL,
                      measures = c("M0","H","A"),
                      indmeasures = c("hd","hdk","actb","pctb"), indklist = NULL,
                      over = NULL, ...,
                      cotyear = NULL, tvar = NULL,
                      cotmeasures = c("M0","H","A","hd","hdk"), ann = TRUE, cotklist = NULL,
                      nooverall = FALSE, level = 0.95,
                      multicore = getOption("mpitb.multicore")){

# Catch call --------------------------------------------------------------

  # Get the formal arguments with default values
  formalArgs <- formals(mpitb.est)
  # Get the arguments passed to the function
  myArgs <- as.list(match.call(expand.dots = FALSE))[-1]
  # Add any missing arguments from formals
  for (v in names(formalArgs)) {
    if (!(v %in% names(myArgs))) {
      myArgs <- append(myArgs, formalArgs[v])
    }
  }
  myArgs$... <- NULL


  this.call <- match.call(expand.dots = FALSE)
  # Print this call so that the user can check if arguments are correctly assigned
  print(this.call)

# 1) Check arguments ------------------------------------------------------

  Args <- do.call(".checkArgs_est", myArgs)
  ## Get the checked arguments
  set = Args$set # ok
  klist = Args$klist # ok the checks

  weights = Args$weights # if numeric, do nothing; else if "equal", get the nested weights
  measures = Args$measures #

  indmeasures = Args$indmeasures #
  indklist = Args$indklist

  over = Args$over # ok the checks -> already with noverall done

  cotyear = Args$cotyear
  tvar = Args$tvar
  cotmeasures = Args$cotmeasures
  ann = Args$ann
  cotklist = Args$cotklist

  nooverall = Args$nooverall # ok the checks
  level = Args$level # ok the checks

  nomeasures = Args$nomeasures
  noindmeasure = Args$noindmeasures

  print(nomeasures)
  print(noindmeasure)

# 2) Arguments treatment --------------------------------------------------

  ### 2.1) WEIGHTS, INDICATORS AND DIMENSIONS ####
  {# `indicators` is a list and it is in `set`
  indicators <- set$indicators
  # if `weights` == "equal", create nested weights
  if (grepl(weights,"equal")) {
    # equal weights for each dimension
    weight_dim <- 1/length(indicators)
    weights_dim <- rep(weight_dim, length(indicators))
    # equal weights for each indicator
    weights_ind <- sapply(indicators, function(x) rep(1/length(x) * weight_dim,length(x)))
    # weights and indicators as ordered vectors such that each indicator match its corresponding weights
    weights <- unlist(weights_ind, use.names = F)
    indicators <- unlist(indicators, use.names = F)
    names(weights) <- indicators
  } else { # if `weights` is numeric and sum up to 1 (preferred weights specification)
    # indicators as a vector
    indicators <- unlist(indicators, use.names = F)
    names(weights) <- indicators
  }
  print(indicators)
  print(weights)
  # RESULTS
  # indicators <- character: Names of the indicators
  # weights <- numeric: Relative weights of the indicators in the same order as the vector
# End of '2.1) WEIGHTS, INDICATORS AND DIMENSIONS'
}
  ### 2.2) CALCULATE THE DEPRIVATION SCORE ####
  {# `data` is in`set`
  data <- set$data
  g0 <- g0.matrix(data, indicators)
  ## G0_w <- matrix: Weighted Deprivation Matrix
  g0_w <- weighted.g0.matrix(g0, weights)
  # calculate the deprivations score
  deprivations.score <- c.score(g0_w)
  ### Add deprivations score to survey variables data frame (see utils.R)
  data <- update.svy(data, c.score = deprivations.score)
  # RESULTS:
  # data <- survey.design: Survey design with the deprivations score
# End of '2.2) CALCULATE THE DEPRIVATION SCORE'
  }
  ### 2.3) CHANGES OVER TIME VARIABLES ####
  {
  if (!is.null(tvar)){
    # create a logical variable `cot`  if `tvar` is not null
    cot <- TRUE
    # if the years are missing, annualized measures cannot be calculated
    if (is.null(cotyear) & isTRUE(ann)){
      # if `cotyear` is null `ann` cannot be TRUE
      ann <- FALSE
      warning("Years for changes over time measures (`cotyear`) are not specified but `ann` is TRUE.
            Hence, `ann` is coerced to FALSE and non-annualized measures are only calculated.")
    } else if (!is.null(cotyear) & isFALSE(ann)) {
      ann <- FALSE
      warning("Years for changes over time measures (`cotyear`) are specified but `ann` is FALSE.
            Hence, `ann` is coerced to FALSE and non-annualized measures are only calculated.")
    }
  } else {cot <- FALSE}
  # RESULTS:
  # cot -> logical: If TRUE, COT measure are calculated
  # tvar, cotyear, ann, cotklist (character, character, logical, numeric)
  # cotmeasures (character)
# End of '2.3) CHANGES OVER TIME VARIABLES'
  }

  ### 2.4) PARALLEL PROCESSING
  if(multicore && !requireNamespace("parallel",quietly=TRUE)) {
    multicore <- FALSE
  }
  if(multicore){print("Parallel calculations by measures and poverty cutoffs")}

# 3) AF measures ----------------------------------------------------------

  ctype_lev <- list()

  if(isFALSE(nomeasures)){
    # arguments to vectorize over
    VecArgs <- expand.grid(list(k = klist, measure = measures), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
    # MoreArgs (a list of other arguments to the mpitb measures FUN)
    OtherArgs <- list(data = data, over = over,
                     cot = cot, tvar = tvar,
                     level = level)


    # estimate each measure by poverty cutoff k
    # include parallel processing
    AFmeasuresList <-  (if (multicore) parallel::mcmapply else mapply)(mpitb.measure, prop = TRUE, k = VecArgs$k, measure = VecArgs$measure, MoreArgs = OtherArgs, SIMPLIFY = FALSE, USE.NAMES = FALSE)

    cat("DONE: Cross-section AF partial measures estimated\n")
    } else if ((isFALSE(nomeasures) & isFALSE(cot)) & isFALSE(noindmeasure))  {
      warning("Neither cross-section of AF measures nor changes over time estimates are set. Only indicators related measures such as censored and uncensored headcount ratios can be calculated.")
    }

# 4) Indicators-related measures ------------------------------------------

# This include hd, hdk, actb and pctb ####
    if (isFALSE(noindmeasure)){

      # if indklist is NULL, use the same klist as in cross-sectional AF measures
      if(is.null(indklist)){indklist <- klist}

      # separate measures
      contmeasures <- c("actb","pctb")[c("actb","pctb") %in% indmeasures]
      indmeasures <- c("hd","hdk")[c("hd","hdk") %in% indmeasures]

      # arguments to vectorize over
      VecArgs <- expand.grid(list(k = klist, indmeasure = indmeasures, indicator = indicators), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)

      # MoreArgs (a list of other arguments to the mpitb measures FUN)
      OtherArgs <- list(data = data, over = over,
                      cot = cot, tvar = tvar,
                      level = level)

      # estimate each measure by poverty cutoff k
      # include parallel processing
      indmeasuresList <- (if (multicore) parallel::mcmapply else mapply)(mpitb.indmeasure, prop = TRUE, k = VecArgs$k, indmeasure = VecArgs$indmeasure, indicator = VecArgs$indicator, MoreArgs = OtherArgs, SIMPLIFY = FALSE, USE.NAMES = FALSE)

      # convert to data frame
      indmeasuresList <- do.call("rbind", indmeasuresList)
      cat("DONE: Cross-section other indicators-related partial measures estimated\n")
  }

# 5) Changes over time measures -------------------------------------------

# This include absolute and relative (annualized) changes ####
  if(isTRUE(cot)){
    # if cotklist is NULL, use the same klist as in cross-sectional AF measures
    if(is.null(cotklist)){cotklist <- klist}


    indmeasures <- c("hd","hdk")[c("hd","hdk") %in% cotmeasures]
    cotmeasures <- c("M0","A","H")[c("M0","A","H") %in% cotmeasures]


    # arguments to vectorize over
    VecArgs <- expand.grid(list(k = cotklist, measure = cotmeasures, indicator = NA), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
    VecArgs <- rbind(VecArgs, expand.grid(list(k = cotklist, measure = indmeasures, indicator = indicators), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE))
    # MoreArgs (a list of other arguments to the mpitb cotmeasures FUN)
    OtherArgs <- list(data = data, over = over,
                      tvar = tvar, cotyear = cotyear,
                      level = level)


    measuresList <- (if (multicore) parallel::mcmapply else mapply)(mpitb.measure, prop = FALSE, k = VecArgs$k, measure = VecArgs$measure, MoreArgs = OtherArgs, SIMPLIFY = FALSE, USE.NAMES = FALSE)


    measuresList <- unlist(measuresList, recursive = FALSE)

    # Calculate (annualized) absolute and relative changes

      # match `tvar` and `cotyear`
    if(isTRUE(ann)){
      years.list <- sort(unique(data$variables[,cotyear]))
      names(years.list) <- sort(as.character(unique(data$variable[,tvar])))
      annualized <- c(FALSE,TRUE)
      } else {
        years.list <- sort(as.character(unique(data$variables[,tvar])))
        names(years.list) <- sort(as.character(unique(data$variables[,tvar])))
        annualized <- c(FALSE)
      }
    # arguments to vectorize over
    VecArgs <- expand.grid(list(change.measure = c("abs","rel"), annualized = annualized), KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)

    # MoreArgs (a list of other arguments to the mpitb cotmeasures FUN)

    OtherArgs <- list(years.list = years.list, object = measuresList,
                      level = level, degfs = survey::degf(data))
    cotmeasuresList <- (if (multicore) parallel::mcmapply else mapply)(mpitb.cotmeasure, change.measure = VecArgs$change.measure, annualized = VecArgs$annualized, MoreArgs = OtherArgs, SIMPLIFY = FALSE, USE.NAMES = FALSE)
    cotmeasuresList <- do.call("rbind",unlist(cotmeasuresList, recursive = FALSE))
  }

  return(indmeasuresList)
}








