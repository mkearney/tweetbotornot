join_rtweet <- function(x) {
  if ("users" %in% names(attributes(x))) {
    ## get users data and drop screen name
    u <- attr(x, "users")
    u <- u[, names(u) != "screen_name"]
    ## remove duplicate user rows
    u <- u[!duplicated(u$user_id), ]
    ## merge tweets and users data
    x <- merge(x, u, by = "user_id")
    ## remove duplicate tweet rows
    x <- x[!duplicated(x$status_id), ]
    x <- tibble::as_tibble(x, validate = FALSE)
  } else if ("tweets" %in% names(attributes(x))) {
    ## get tweets data and drop screen_name
    w <- attr(x, "tweets")
    w <- w[, names(w) != "screen_name"]
    ## remove duplicate user rows
    x <- x[!duplicated(x$user_id), ]
    ## merge tweets and users data
    x <- merge(x, w, by = "user_id")
    ## order by date and then remove duplicate tweet rows
    x <- x[!duplicated(x$status_id), ]
    x <- tibble::as_tibble(x, validate = FALSE)
  }
  x
}

convert_factors <- function(x) {
  fcts <- vap_lgl(x, is.factor)
  if (sum(fcts) == 0L) {
    return(x)
  }
  x[fcts] <- lapply(x[fcts], as.character)
  x
}

vap_lgl <- function(.x, .f) {
  vapply(.x, rlang::as_closure(.f), FUN.VALUE = logical(1), USE.NAMES = FALSE)
}
vap_dbl <- function(.x, .f) {
  vapply(.x, rlang::as_closure(.f), FUN.VALUE = numeric(1), USE.NAMES = FALSE)
}
vap_int <- function(.x, .f) {
  vapply(.x, rlang::as_closure(.f), FUN.VALUE = integer(1), USE.NAMES = FALSE)
}
vap_fct <- function(.x, .f) {
  vapply(.x, rlang::as_closure(.f), FUN.VALUE = factor(1), USE.NAMES = FALSE)
}
vap_chr <- function(.x, .f) {
  vapply(.x, rlang::as_closure(.f), FUN.VALUE = character(1), USE.NAMES = FALSE)
}



tw_or_usr <- function(x) {
  num_tweets <- sum(c("text", "source", "mentions_screen_name", "retweet_count",
    "favorite_count", "hashtags") %in% names(x), na.rm = TRUE)
  num_users <- sum(c("name", "followers_count", "favourites_count", "friends_count",
    "account_created_at", "description") %in% names(x), na.rm = TRUE)
  if (num_tweets > 3 && num_users > 3) {
    return("both")
  }
  if (num_tweets > num_users) {
    return("tweets")
  }
  if (num_users > num_tweets) {
    return("users")
  }
}


hourofweekday <- function(x) {
  h <- as.numeric(substr(x, 12, 13))
  m <- as.numeric(substr(x, 15, 16)) / 60
  hms <- round(timeofday(x), 0)
  wd <- format(x, "%a")
  wd <- as.integer(factor(
    wd, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))) * 24
  (wd + hms) / 24
}

timeofday <- function(x) {
  h <- as.numeric(substr(x, 12, 13))
  m <- as.numeric(substr(x, 15, 16)) / 60
  s <- as.numeric(substr(x, 18, 19)) / 360
  h + m + s
}
count_mean <- function(x) {
  if (length(x) == 1L && is.na(x)) return(NA_real_)
  x <- table(x)
  x <- as.integer(x) - 1L
  mean(x, na.rm = TRUE)
}
