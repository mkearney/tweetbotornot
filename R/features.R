


train_data <- function() botornot$train
test_data <- function() botornot$test

## feature extraction

## is double
is_num <- function(x) is.numeric(x) | is.integer(x)

n_words <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  x <- gsub("\\d", "", x)
  x <- strsplit(x, "\\s+")
  x <- lengths(x)
  x[na] <- NA_integer_
  x
}

n_digits <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  x <- nchar(gsub("\\D", "", x))
  x[na] <- NA_integer_
  x
}

n_hashtags <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  m <- gregexpr("#\\S+", x)
  m <- regmatches(x, m)
  x <- lengths(m)
  x[na] <- NA_integer_
  x
}

n_mentions <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  m <- gregexpr("@\\S+", x)
  m <- regmatches(x, m)
  x <- lengths(m)
  x[na] <- NA_integer_
  x
}

n_commas <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  m <- gregexpr(",+", x)
  m <- regmatches(x, m)
  x <- lengths(m)
  x[na] <- NA_integer_
  x
}

n_caps <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  m <- gregexpr("[A-Z]", x)
  m <- regmatches(x, m)
  x <- lengths(m)
  x[na] <- NA_integer_
  x
}

n_urls <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  m <- gregexpr("https?:", x)
  m <- regmatches(x, m)
  x <- lengths(m)
  x[na] <- NA_integer_
  x
}

extract_features <- function(data) {
  users <- unique(data$user_id)
  o <- vector("list", length(users))
  for (i in seq_along(users)) {
    o[[i]] <- extract_features_group(data[data$user_id == users[i], ])
  }
  tibble::as_tibble(do.call("rbind", o), validate = FALSE)
}

n_cap_words <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  m <- gregexpr("\\b[A-Z]+\\b", x)
  m <- regmatches(x, m)
  x <- lengths(m)
  x[na] <- NA_integer_
  x
}

all_lower <- function(x) {
  na <- is.na(x)
  if (all(na)) return(0)
  x <- gsub("@\\S+", "", x)
  m <- gregexpr("\\b[a-z]+\\b", x)
  m <- regmatches(x, m)
  x <- lengths(m)
  x[na] <- NA_integer_
  x
}

extract_features_group <- function(data) {
  if (length(unique(data$user_id)) > 1L) {
    stop("this should be for 1 user at a time")
  }
  n_retweets <- sum(data$is_retweet, na.rm = TRUE)
  n_quotes <- sum(data$is_quote, na.rm = TRUE)
  has_tweet <- as.integer(any(!is.na(data$text)))
  data$text[data$is_retweet] <- NA_character_
  tweet_chars <- mean(nchar(data$text), na.rm = TRUE)
  data$retweet_count[data$is_retweet] <- NA_integer_
  retweet_count <- mean(data$retweet_count, na.rm = TRUE)
  favorite_count <- mean(data$favorite_count, na.rm = TRUE)
  favourites_count <- max(data$favourites_count, na.rm = TRUE)
  n_mentions <- mean(n_mentions(data$text), na.rm = TRUE)
  n_links <- mean(n_urls(data$text), na.rm = TRUE)
  n_hashtag <- mean(n_hashtags(data$text), na.rm = TRUE)
  n_capwords <- mean(n_cap_words(data$text), na.rm = TRUE)
  all_lowers <- mean(all_lower(data$text), na.rm = TRUE)
  ## number of pure tweets
  n_tweets <- sum(!data$is_retweet & !data$is_quote, na.rm = TRUE)
  iphone <- sum(data$source == "Twitter for iPhone", na.rm = TRUE) / nrow(data)
  webclient <- sum(data$source == "Twitter Web Client", na.rm = TRUE) / nrow(data)
  ios <- sum(data$source == "Tweetbot for iΟS", na.rm = TRUE) / nrow(data)
  android <- sum(data$source == "Twitter for Android", na.rm = TRUE) / nrow(data)
  hootsuite <- sum(data$source == "Hootsuite", na.rm = TRUE) / nrow(data)
  lite <- sum(data$source == "Twitter Lite", na.rm = TRUE) / nrow(data)
  ipad <- sum(data$source == "Twitter for iPad", na.rm = TRUE) / nrow(data)
  google <- sum(data$source == "Google", na.rm = TRUE) / nrow(data)
  ifttt <- sum(data$source == "IFTTT", na.rm = TRUE) / nrow(data)
  facebook <- sum(data$source == "Facebook", na.rm = TRUE) / nrow(data)
  dsc <- unique(data$description)[1]
  bio_chars <- nchar(dsc)
  bio_hts <- n_hashtags(dsc)
  bio_sns <- n_mentions(dsc)
  bio_caps <- n_caps(dsc)
  loc <- unique(data$location)[1]
  loc_chars <- nchar(loc)
  loc_commas <- n_commas(loc)
  nm <- unique(data$name)[1]
  name_chars <- nchar(nm)
  name_words <- n_words(nm)
  name_caps <- n_caps(nm)
  sn <- unique(data$screen_name)[1]
  sn_digits <- n_digits(sn)
  verified <- as.integer(any(data$verified))
  aca <- unique(data$account_created_at)[1]
  years <- as.numeric(
    difftime(Sys.time(), aca, units = "days")) / 365
  data$created_at <- as.POSIXct(ifelse(is.na(data$created_at),
    Sys.time() - 60 * 60 * 24 * 365, data$created_at),
    origin = "1970-01-01", tz = "UTC")
  days_since_tweet <- round(as.numeric(difftime(Sys.time(),
    max(data$created_at, na.rm = TRUE), units = "days")), 0)
  ## i added one here so it wouldn't return NaN or undefined values (0 / x)
  statuses_count <- max(data$statuses_count, na.rm = TRUE)
  followers_count <- max(data$followers_count, na.rm = TRUE)
  friends_count <- max(data$friends_count, na.rm = TRUE)
  listed_count <- max(data$listed_count, na.rm = TRUE)
  tweets_to_followers <- (statuses_count + 1) / (followers_count + 1)
  statuses_rate <- statuses_count / years
  ## i added one here so it wouldn't return NaN or undefined values (0 / x)
  ff_ratio <- (followers_count + 1) / (friends_count + followers_count + 1)
  user_id <- unique(data$user_id)[1]

  data.frame(
    user_id, screen_name = sn, tweet_chars, years,
    n_retweets, n_quotes, has_tweet, n_mentions,
    retweet_count, favorite_count, favourites_count,
    n_links, n_hashtag, n_capwords, all_lowers,
    n_tweets, iphone, webclient, ios, android,
    hootsuite, lite, ipad, google, ifttt,
    facebook, bio_chars, bio_hts, bio_sns,
    bio_caps, loc_chars, loc_commas, name_chars,
    name_words, name_caps, days_since_tweet,
    sn_digits, verified, statuses_count, friends_count,
    followers_count, listed_count, tweets_to_followers,
    statuses_rate, ff_ratio,
    stringsAsFactors = FALSE
  )
}

train_model <- function(data, n_trees = 1000) {
  data <- data[!vap_lgl(data, ~ all(is.na(.)) || any(lengths(.) != 1L))]
  data <- data[vap_lgl(data, ~ is.numeric(.) | is.integer(.))]
  ## set params and run model (~ . means use all other variables)
  gbm::gbm(bot ~ .,
    data = data,
    n.trees = n_trees,
    interaction.depth = 2,
    cv.folds = 3,
    train.fraction = 1.0,
    verbose = FALSE,
    distribution = "bernoulli",
    shrinkage = .1)
}


## write a function to print out the percent correct (overall; for bots, and
## for non-bots)
percent_correct <- function(data, m, n_trees = 500) {
  best.iter <- gbm::gbm.perf(m, method = "cv", plot.it = FALSE)
  data$pred <- gbm::predict.gbm(m, newdata = data,
    n.trees = best.iter, type = "response")
  x <- table(correct = data$pred > .5, bot = data$bot)
  pc <- round((x[2, 2]) / sum(x[, 2]), 4)
  pc <- as.character(pc * 100)
  message(sprintf("The model was %s%% accurate when classifying bots.\n", pc))
  pc <- round((x[1, 1]) / sum(x[, 1]), 4)
  pc <- as.character(pc * 100)
  message(sprintf("The model was %s%% accurate when classifying non-bots.\n",
    pc))
  pc <- round((x[1, 1] + x[2, 2]) / sum(c(x[, 1], x[, 2])), 3)
  pc <- as.character(pc * 100)
  message(sprintf("Overall, the model was correct %s%% of the time.", pc))
}

#' classify data
#'
#' Generate predicted probabilities of observations being bots.
#'
#' @param x New data on which to apply botornot model.
#' @return Vector of predictions expressed as probabilities of accounts being
#'   bots.
#' @export
classify_data <- function(x) {
  best.iter <- gbm::gbm.perf(botornot_model, method = "cv", plot.it = FALSE)
  gbm::predict.gbm(botornot_model, n.trees = best.iter, newdata = x,
    type = "response")
}
