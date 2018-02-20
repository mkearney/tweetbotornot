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
  ## convert factors to char if necessary
  x <- convert_factors(x)
  ## merge users and tweets data
  x <- rtweet_join(x)
  ## extract any misssing features
  x <- extract_features(x)
  ## store screen names
  sn <- x$screen_name
  ## classify data
  p <- classify_data(x)
  ## return as tibble
  tibble::as_tibble(
    data.frame(user = sn, prob_bot = p, stringsAsFactors = FALSE),
    validate = FALSE)
}

#' @export
botornot.factor <- function(x) {
  x <- as.character(x)
  botornot(x)
}

#' @export
botornot.character <- function(x) {
  ## remove NA and duplicates
  x <- x[!is.na(x) & !duplicated(x)]
  ## get most recent 200 tweets
  x <- rtweet::get_timelines(x, n = 100)
  ## pass to next method
  botornot(x)
}
