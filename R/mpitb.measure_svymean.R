mpitb.measure_svymean <- function(measure = c("M0","H","A","hd","hdk"), ...){
  measure <- match.arg(measure)
  dots <- list(...)
  if(length(dots) == 0) dots <- NULL
  selected.measure <- switch(measure,
                             M0 = do.call("mpitb.cot.M0", dots),
                             H = do.call("mpitb.cot.H", dots),
                             A = do.call("mpitb.cot.A", dots))
  selected.measure
}
