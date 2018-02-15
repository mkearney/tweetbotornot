#' botornot
#'
#' Classify users/accounts in Twitter data as bots or not bots.
#'
#' @param x Object to be classified. Can be user IDs, screen names, or
#'   data frames returned by rtweet.
#' @return Classifications for all users expressed as probability of whether
#'   each account is a bot.
#' @export
botornot <- function(x) UseMethod("botornot")

#' @export
botornot.data.frame <- function(x) {
  ## store original order of users
  x_ <- x$user_id
  ## merge users and tweets data
  x <- rtweet_join(x)
  ## remove duplicate users
  x <- x[!duplicated(x$user_id), ]
  ## extract any misssing features
  x <- extract_features(x)
  ## classify data
  p <- classify_data(x)
  ## match positions
  o <- match(x$user_id, x_)
  ## preserve NAs and match p values
  o[!is.na(o)] <- p[!is.na(o)]
  ## return output
  o
}

#' @export
botornot.character <- function(x) {
  ## store original
  x_ <- x
  ## remove NA and duplicates
  x <- x[!is.na(x) & !duplicated(x)]
  ## lookup users data
  x <- rtweet::lookup_users(x)
  ## merge users and tweets data
  x <- rtweet_join(x)
  ## remove duplicate users
  x <- x[!duplicated(x$user_id), ]
  ## pass to next method
  botornot(x)
}
