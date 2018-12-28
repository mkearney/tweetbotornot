

convert_factors <- function(x) {
  fcts <- vap_lgl(x, is.factor)
  if (sum_(fcts) == 0L) {
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
  if (length(x) == 0) return(0)
  if (length(x) == 1L && is.na(x) || all(is.na(x))) return(0)
  x <- table(x)
  x <- as.integer(x) - 1L
  mean(x, na.rm = TRUE)
}


nchar_ <- function(x) {
  ifelse(is.na(x), 0, nchar(x))
}


ndigit_ <- function(x) {
  ifelse(is.na(x), 0, nchar(gsub("\\D", "", x)))
}

