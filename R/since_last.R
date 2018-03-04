since_last <- function(x, units = "mins") UseMethod("since_last")

since_last.data.frame <- function(x, units = "mins") {
  if (!"created_at" %in% names(x)) {
    stop("can't find created_at (tweet timestamp) variable")
  }
  ## store input positions
  x_ <- order(x$created_at)
  ## arrange by date-time
  x <- x[order(x$created_at), ]
  ## calculate since last and store as variable
  x$since_last <- as.numeric(
    difftime(x$created_at, c(as.POSIXct(NA), x$created_at[-length(x$created_at)]),
      units = units))
  ## replace nans
  x$since_last[is.nan(x$since_last)] <- NA_real_
  ## match input positions
  x[x_, ]
}

since_last.POSIXct <- function(x, units = "mins") {
  ## store input positions
  x_ <- order(x)
  ## arrange by date-time
  x <- sort(x)
  ## calculate since last
  x <- as.numeric(difftime(x, c(as.POSIXct(NA), x[-length(x)]), units = units))
  ## replace nans
  x[is.nan(x)] <- NA_real_
  ## match input positions
  x[x_]
}

since_last.default <- function(x, units = "mins") {
  if (!inherits(x, c("numeric", "integer"))) {
    stop("input data must be a data frame, POSIXct, numeric, or integer")
  }
  ## store input positions
  x_ <- order(x)
  ## arrange by value
  x <- sort(x)
  ## calculate since last
  x <- x - c(NA, x[-length(x)])
  ## replace nans
  x[is.nan(x)] <- NA_real_
  ## match input positions
  x[x_]
}

since_last.grouped_df <- function(x, units = "mins") {
  dplyr::mutate(x, since_last = since_last(created_at))
}


