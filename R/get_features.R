

get_features <- function(x) UseMethod("get_features")

dup_mean <- function(x) {
  x <- table(x)
  x <- as.integer(x) - 1L
  mean_(x)
}

dup_mins <- function(x) {
  x <- as.numeric(gsub(":", "", substr(x, 15, 18)))
  dup_mean(x)
}


var_ <- function(x) {
  if (length(x) == 1L && is.na(x)) return(NA)
  var(x, na.rm = TRUE)
}
max_ <- function(x)  {
  if (length(x) == 1L && is.na(x)) return(NA)
  max(x, na.rm = TRUE)
}
sum_ <- function(x)  {
  if (length(x) == 1L && is.na(x)) return(NA)
  sum(x, na.rm = TRUE)
}
mean_ <- function(x)  {
  if (length(x) == 1L && is.na(x)) return(NA)
  mean(x, na.rm = TRUE)
}
median_ <- function(x)  {
  if (length(x) == 1L && is.na(x)) return(NA)
  median(x, na.rm = TRUE)
}
rec_length <- function(x) {
  l <- lengths(x)
  l[vap_lgl(x[l == 1L], is.na)] <- 0L
  l
}

timeofweekday <- function(x) {
  hms <- timeofday(x)
  wd <- format(x, "%a")
  wd <- as.integer(factor(wd, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))) * 24
  (wd + hms) / 24
}

timeofday <- function(x) {
  h <- as.numeric(substr(x, 12, 13))
  m <- as.numeric(substr(x, 15, 16)) / 60
  s <- as.numeric(substr(x, 18, 19)) / 360
  h + m + s
}

get_features.data.frame <- function(x) {
  x <- dplyr::group_by(x, user_id)
  x <- since_last(x)
  x <- dplyr::summarise(x,
    n_retweets = sum_(is_retweet),
    n_quotes = sum_(is_quote),
    n_tweets = sum_(!is_retweet & !is_quote),
    n_favorite = mean_(favorite_count),
    n_favourites = max_(favourites_count),
    n_mentions = mean_(rec_length(mentions_user_id)),
    n_sincelast = dup_mean(since_last(created_at)),
    n_timeofday = dup_mean(timeofday(created_at))
    )
  x
}
