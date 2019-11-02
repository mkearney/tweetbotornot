utils::globalVariables(c("account_created_at", "created_at", "favorite_count",
  "favourites_count", "followers_count", "friends_count", "is_quote",
  "is_retweet", "listed_count", "n", "n_tweets", "retweet_count",
  "statuses_count", "text", "user_id", "verified", "years_on_twitter",
  "description", "location", "name"))

sum_ <- function(x) sum(x, na.rm = TRUE)

sd_ <- function(x) {
  if (length(x) == 1 || all(is.na(x))) return(0)
  sd(x, na.rm = TRUE)
}

range_ <- function(x) {
  if (length(x) == 1 || all(is.na(x))) return(0)
  abs(max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}

max_ <- function(x) max(x, na.rm = TRUE)

mean_ <- function(x) mean(x, na.rm = TRUE)

grepl_ <- function(pat, x) grepl(pat, x)

#' @importFrom rlang .data
extract_features_ytweets <- function(x) {
  ## remove retweet text and counts
  x$text[x$is_retweet] <- NA_character_
  x$retweet_count[x$is_retweet] <- NA_integer_

  ## remove user level duplicates
  x_usr <- dplyr::filter(x, !duplicated(.data$user_id))

  ## tweet features
  txt_df <- tf(
    dplyr::select(x[!is.na(x$text), ], user_id = user_id, text = text),
    verbose = TRUE)
  txt_df <- cbind(user_id = x$user_id[!is.na(x$text)], txt_df, stringsAsFactors = FALSE)
  names(txt_df)[-1] <- paste0("txt_", names(txt_df)[-1])

  ## base64 version
  b64_df <- tf(
    dplyr::select(x[!is.na(x$text), ], user_id = user_id, text = text))
  b64_df <- cbind(user_id = x$user_id[!is.na(x$text)], b64_df, stringsAsFactors = FALSE)
  names(b64_df)[-1] <- paste0("b64_", names(b64_df)[-1])

  dsc_df <- tf(
    dplyr::select(x_usr, user_id = user_id, text = description))
  dsc_df <- cbind(user_id = x_usr$user_id, dsc_df, stringsAsFactors = FALSE)
  names(dsc_df)[-1] <- paste0("dsc_", names(dsc_df)[-1])

  loc_df <- tf(
    dplyr::select(x_usr, user_id = user_id, text = location))
  loc_df <- cbind(user_id = x_usr$user_id, loc_df)
  names(loc_df)[-1] <- paste0("loc_", names(loc_df)[-1])

  nm_df <- tf(
    dplyr::select(x_usr, user_id = user_id, text = name))
  nm_df <- cbind(user_id = x_usr$user_id, nm_df, stringsAsFactors = FALSE)
  names(nm_df)[-1] <- paste0("nm_", names(nm_df)[-1])

  dd1 <- cbind(txt_df, b64_df[-1])
  dd2 <- cbind(dsc_df, loc_df[-1])
  dd2 <- cbind(dd2, nm_df[-1], stringsAsFactors = FALSE)
  dd <- dplyr::left_join(dd1, dd2, by = "user_id")

  x <- x %>%
    dplyr::group_by(user_id) %>%
    dplyr::summarise(
      n_sincelast = count_mean(since_last(.data$created_at)),
      n_timeofday = count_mean(hourofweekday(.data$created_at)),
      n = dplyr::n(),
      n_retweets = sum_(.data$is_retweet),
      n_quotes = sum_(.data$is_quote),
      retweet_count = mean_(c(0, .data$retweet_count)),
      favorite_count = mean_(c(0, .data$favorite_count)),
      favourites_count = max_(c(0, .data$favourites_count)),
      n_tweets = sum_(!.data$is_retweet & !.data$is_quote),
      iphone = sum_(grepl_("iphone", .data$source)) / .data$n,
      webclient = sum_(grepl_("web client", .data$source)) / .data$n,
      android = sum_(grepl_("android", .data$source)) / .data$n,
      hootsuite = sum_(grepl_("hootsuite", .data$source)) / .data$n,
      lite = sum_(grepl_("twitter lite", .data$source)) / .data$n,
      ipad = sum_(grepl_("for iPad", .data$source)) / .data$n,
      google = sum_(grepl_("google", .data$source)) / .data$n,
      ifttt = sum_(grepl_("IFTTT", .data$source)) / .data$n,
      facebook = sum_(grepl_("facebook", .data$source)) / .data$n,
      verified = as.integer(.data$verified[1]),
      years_on_twitter = as.numeric(
        difftime(Sys.time(), .data$account_created_at[1], units = "days")) / 365,
      tweets_per_year = .data$n_tweets / (1 + .data$years_on_twitter),
      ## i added one here so it wouldn't return NaN or undefined values (0 / x)
      statuses_count = max_(c(0, .data$statuses_count)),
      followers_count = max_(c(0, .data$followers_count)),
      friends_count = max_(c(0, .data$friends_count)),
      listed_count = max_(c(0, .data$listed_count)),
      tweets_to_followers = (.data$statuses_count + 1) /
        (.data$followers_count + 1),
      statuses_rate = (.data$statuses_count + 1) /
        (.data$years_on_twitter + .001),
      ff_ratio = (.data$followers_count + 1) /
        (.data$friends_count + .data$followers_count + 1)
    )
  x <- x[names(x) != "n"]
  dplyr::full_join(x, dd, by = "user_id") %>%
    dplyr::group_by(user_id) %>%
    dplyr::summarise_all(mean, na.rm = TRUE) %>%
    dplyr::ungroup()
}

train_model <- function(data, n_trees = 1000) {
  data <- data[!purrr::map_lgl(data,
    ~ all(is.na(.x)) || any(lengths(.x) != 1L))]
  data <- data[purrr::map_lgl(data, ~ is.numeric(.x) | is.integer(.x))]
  data <- data[purrr::map_lgl(data, ~ var(.x) > 0)]
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
  pc <- round((x[2, 2]) / sum_(x[, 2]), 4)
  pc <- as.character(pc * 100)
  message(sprintf("The model was %s%% accurate when classifying bots.\n", pc))
  pc <- round((x[1, 1]) / sum_(x[, 1]), 4)
  pc <- as.character(pc * 100)
  message(sprintf("The model was %s%% accurate when classifying non-bots.\n",
    pc))
  pc <- round((x[1, 1] + x[2, 2]) / sum_(c(x[, 1], x[, 2])), 3)
  pc <- as.character(pc * 100)
  message(sprintf("Overall, the model was correct %s%% of the time.", pc))
}


classify_data <- function(x, model) {
  ##best.iter <- gbm::gbm.perf(model, method = "cv", plot.it = FALSE)
  gbm::predict.gbm(model, n.trees = 700, newdata = x,
    type = "response")
}




tf <- function(x, sentiment = TRUE, verbose = FALSE) {
  textfeatures::textfeatures(x, sentiment = sentiment, normalize = FALSE, word_dims = 0, verbose = verbose)
}





extract_features_ntweets <- function(x) {
  ## remove retweet text and counts
  #x$text[x$is_retweet] <- NA_character_
  #x$retweet_count[x$is_retweet] <- NA_integer_

  ## remove user level duplicates
  x_usr <- dplyr::filter(x, !duplicated(.data$user_id))

  ## tweet features
  txt_df <- tf(
    dplyr::select(x, user_id = user_id, text = text),
    verbose = TRUE,
    sentiment = FALSE)
  txt_df <- cbind(user_id = x$user_id, txt_df, stringsAsFactors = FALSE)
  names(txt_df)[-1] <- paste0("txt_", names(txt_df)[-1])

  ## base64 version
  b64_df <- tf(
    dplyr::select(x, user_id = user_id, text = text),
    sentiment = FALSE)
  b64_df <- cbind(user_id = x$user_id, b64_df, stringsAsFactors = FALSE)
  names(b64_df)[-1] <- paste0("b64_", names(b64_df)[-1])

  dsc_df <- tf(
    dplyr::select(x_usr, user_id = user_id, text = description),
    sentiment = FALSE)
  dsc_df <- cbind(user_id = x_usr$user_id, dsc_df, stringsAsFactors = FALSE)
  names(dsc_df)[-1] <- paste0("dsc_", names(dsc_df)[-1])

  loc_df <- tf(
    dplyr::select(x_usr, user_id = user_id, text = location),
    sentiment = FALSE)
  loc_df <- cbind(user_id = x_usr$user_id, loc_df)
  names(loc_df)[-1] <- paste0("loc_", names(loc_df)[-1])

  nm_df <- tf(
    dplyr::select(x_usr, user_id = user_id, text = name),
    sentiment = FALSE)
  nm_df <- cbind(user_id = x_usr$user_id, nm_df, stringsAsFactors = FALSE)
  names(nm_df)[-1] <- paste0("nm_", names(nm_df)[-1])

  dd1 <- cbind(txt_df, b64_df[-1])
  dd2 <- cbind(dsc_df, loc_df[-1])
  dd2 <- cbind(dd2, nm_df[-1], stringsAsFactors = FALSE)
  dd <- dplyr::left_join(dd1, dd2, by = "user_id")

  x <- x %>%
    dplyr::group_by(user_id) %>%
    dplyr::summarise(
      favourites_count = max_(c(0, .data$favourites_count)),
      verified = as.integer(.data$verified[1]),
      years_on_twitter = as.numeric(
        difftime(Sys.time(), .data$account_created_at[1], units = "days")) / 365,
      statuses_count = max_(c(0, .data$statuses_count)),
      followers_count = max_(c(0, .data$followers_count)),
      friends_count = max_(c(0, .data$friends_count)),
      listed_count = max_(c(0, .data$listed_count)),
      tweets_to_followers = (.data$statuses_count + 1) /
        (.data$followers_count + 1),
      statuses_rate = (.data$statuses_count + 1) /
        (.data$years_on_twitter + .001),
      ff_ratio = (.data$followers_count + 1) /
        (.data$friends_count + .data$followers_count + 1)
    )
  dplyr::full_join(x, dd, by = "user_id") %>%
    dplyr::group_by(user_id) %>%
    dplyr::summarise_all(mean, na.rm = TRUE) %>%
    dplyr::ungroup()
}

extract_features_ntweetsog <- function(x) {
  ## remove user level duplicates
  x <- dplyr::filter(x, !duplicated(user_id))
  x <- dplyr::group_by(x, user_id)
  ## remove user level duplicates
  #x_usr <- dplyr::filter(x, !duplicated(.data$user_id))

  ## tweet features
  txt_df <- tf(
    dplyr::select(x[!is.na(x$text), ], user_id = user_id, text = text))
  names(txt_df)[-1] <- paste0("txt_", names(txt_df)[-1])
  txt_df[1:ncol(txt_df)] <- apply(txt_df, 2, function(.x)
    ifelse(is.na(.x), 0, .x))

  ## base64 version
  b64_df <- tf(
    dplyr::select(x[!is.na(x$text), ], user_id = user_id, text = text))
  names(b64_df)[-1] <- paste0("b64_", names(b64_df)[-1])
  b64_df[1:ncol(b64_df)] <- apply(b64_df, 2, function(.x)
    ifelse(is.na(.x), 0, .x))

  dsc_df <- tf(
    dplyr::select(x, user_id = user_id, text = description))
  names(dsc_df)[-1] <- paste0("dsc_", names(dsc_df)[-1])
  dsc_df[1:ncol(dsc_df)] <- apply(dsc_df, 2, function(.x)
    ifelse(is.na(.x), 0, .x))

  loc_df <- tf(
    dplyr::select(x, user_id = user_id, text = location))
  names(loc_df)[-1] <- paste0("loc_", names(loc_df)[-1])
  loc_df[1:ncol(loc_df)] <- apply(loc_df, 2, function(.x)
    ifelse(is.na(.x), 0, .x))

  nm_df <- tf(
    dplyr::select(x, user_id = user_id, text = name))
  names(nm_df)[-1] <- paste0("nm_", names(nm_df)[-1])
  nm_df[1:ncol(nm_df)] <- apply(nm_df, 2, function(.x)
    ifelse(is.na(.x), 0, .x))


  dd1 <- cbind(txt_df, b64_df[-1])
  dd2 <- cbind(dsc_df, loc_df[-1])
  dd2 <- cbind(dd2, nm_df[-1])
  dd <- dplyr::left_join(dd1, dd2, by = "user_id")

  x <- x %>%
    dplyr::group_by(user_id) %>%
    dplyr::summarise(
      favourites_count = max_(c(0, favourites_count)),
      verified = as.integer(verified[1]),
      years_on_twitter = as.numeric(
        difftime(Sys.time(), account_created_at[1], units = "days")) / 365,
      ## i added one here so it wouldn't return NaN or undefined values (0 / x)
      statuses_count  = max_(c(0, statuses_count)),
      followers_count  = max_(c(0, followers_count)),
      friends_count  = max_(c(0, friends_count)),
      listed_count  = max_(c(0, listed_count)),
      tweets_to_followers  = (statuses_count + 1) / (followers_count + 1),
      statuses_rate  = (statuses_count + 1) / (years_on_twitter + .001),
      ff_ratio = (followers_count + 1) / (friends_count + followers_count + 1)
    )
  dplyr::left_join(x, dd, by = "user_id")
}

