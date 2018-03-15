utils::globalVariables(c("account_created_at", "created_at", "favorite_count", "favourites_count", "followers_count", "friends_count", "is_quote", "is_retweet", "listed_count", "n", "n_tweets", "retweet_count", "statuses_count", "text", "user_id", "verified", "years_on_twitter", "description"))

extract_features_ytweets <- function(x) {
  ## remove retweet text and counts
  x$text[x$is_retweet] <- NA_character_
  x$retweet_count[x$is_retweet] <- NA_integer_

  ## remove user level duplicates
  x_usr <- dplyr::filter(x, !duplicated(user_id))
  x_usr <- dplyr::group_by(x_usr, user_id)
  ## group by user
  x <- dplyr::group_by(x, user_id)

  ## tweet features
  status_text_df <- dplyr::select_(x, 'user_id', text = 'text')
  status_text_df <- textfeatures::textfeatures(status_text_df)
  names(status_text_df) <- paste0("status_text_", names(status_text_df))

  description_df <- dplyr::select_(x_usr, 'user_id', text = 'description')
  description_df <- textfeatures::textfeatures(description_df)
  names(description_df) <- paste0("description_", names(description_df))

  location_df <- dplyr::select_(x_usr, 'user_id', text = 'location')
  location_df <- textfeatures::textfeatures(location_df)
  names(location_df) <- paste0("location_", names(location_df))

  name_df <- dplyr::select_(x_usr, 'user_id', text = 'name')
  name_df <- textfeatures::textfeatures(name_df)
  names(name_df) <- paste0("name_", names(name_df))

  #all_nas <- function(x) all(is.na(x) | is.nan(x))
  #x <- dplyr::mutate_if(x, is.numeric, function(.) ifelse(all_nas(.), 0, .))

  x <- dplyr::summarise(x,
    n_sincelast = count_mean(since_last(created_at)),
    n_timeofday = count_mean(hourofweekday(created_at)),
    n = n(),
    n_retweets = sum(is_retweet, na.rm = TRUE),
    n_quotes = sum(is_quote, na.rm = TRUE),
    retweet_count = mean(c(0, retweet_count), na.rm = TRUE),
    favorite_count = mean(c(0, favorite_count), na.rm = TRUE),
    favourites_count = max(c(0, favourites_count), na.rm = TRUE),
    n_tweets = sum(!is_retweet & !is_quote, na.rm = TRUE),
    iphone = sum(grepl("iphone", source, ignore.case = TRUE), na.rm = TRUE) / n,
    webclient = sum(grepl("web client", source, ignore.case = TRUE), na.rm = TRUE) / n,
    android = sum(grepl("android", source, ignore.case = TRUE), na.rm = TRUE) / n,
    hootsuite = sum(grepl("hootsuite", source, ignore.case = TRUE), na.rm = TRUE) / n,
    lite = sum(grepl("twitter lite", source, ignore.case = TRUE), na.rm = TRUE) / n,
    ipad = sum(grepl("for iPad", source, ignore.case = TRUE), na.rm = TRUE) / n,
    google = sum(grepl("google", source, ignore.case = TRUE), na.rm = TRUE) / n,
    ifttt = sum(grepl("IFTTT", source, ignore.case = TRUE), na.rm = TRUE) / n,
    facebook = sum(grepl("facebook", source, ignore.case = TRUE), na.rm = TRUE) / n,
    verified = as.integer(verified[1]),
    years_on_twitter = as.numeric(
      difftime(Sys.time(), account_created_at[1], units = "days")) / 365,
    tweets_per_year = n_tweets / (1 + years_on_twitter),
    ## i added one here so it wouldn't return NaN or undefined values (0 / x)
    statuses_count = max(c(0, statuses_count), na.rm = TRUE),
    followers_count = max(c(0, followers_count), na.rm = TRUE),
    friends_count = max(c(0, friends_count), na.rm = TRUE),
    listed_count = max(c(0, listed_count), na.rm = TRUE),
    tweets_to_followers = (statuses_count + 1) / (followers_count + 1),
    statuses_rate = (statuses_count + 1) / (years_on_twitter + .001),
    ff_ratio = (followers_count + 1) / (friends_count + followers_count + 1)
  )
  x <- x[names(x) != "n"]
  dplyr::bind_cols(x, status_text_df, description_df,
    name_df, location_df)
}

train_model <- function(data, n_trees = 1000) {
  data <- data[!vap_lgl(data, ~ all(is.na(.)) || any(lengths(.) != 1L))]
  data <- data[vap_lgl(data, ~ is.numeric(.) | is.integer(.))]
  data <- data[vap_lgl(data, ~ var(.) > 0)]
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
#' @param model gbm model from which to predict.
#' @return Vector of predictions expressed as probabilities of accounts being
#'   bots.
classify_data <- function(x, model) {
  best.iter <- gbm::gbm.perf(model, method = "cv", plot.it = FALSE)
  gbm::predict.gbm(model, n.trees = best.iter, newdata = x,
    type = "response")
}











extract_features_ntweets <- function(x) {
  ## remove user level duplicates
  x <- dplyr::filter(x, !duplicated(user_id))
  x <- dplyr::group_by(x, user_id)
  description_df <- textfeatures::textfeatures(
    dplyr::select(x, user_id, text = description))
  names(description_df) <- paste0("description_", names(description_df))

  location_df <- textfeatures::textfeatures(
    dplyr::select(x, user_id, text = location))
  names(location_df) <- paste0("location_", names(location_df))

  name_df <- textfeatures::textfeatures(
    dplyr::select(x, user_id, text = name))
  names(name_df) <- paste0("name_", names(name_df))

  x <- dplyr::summarise(x,
    favourites_count = max(c(0, favourites_count), na.rm = TRUE),
    verified = as.integer(verified[1]),
    years_on_twitter = as.numeric(
      difftime(Sys.time(), account_created_at[1], units = "days")) / 365,
    ## i added one here so it wouldn't return NaN or undefined values (0 / x)
    statuses_count  = max(c(0, statuses_count), na.rm = TRUE),
    followers_count  = max(c(0, followers_count), na.rm = TRUE),
    friends_count  = max(c(0, friends_count), na.rm = TRUE),
    listed_count  = max(c(0, listed_count), na.rm = TRUE),
    tweets_to_followers  = (statuses_count + 1) / (followers_count + 1),
    statuses_rate  = (statuses_count + 1) / (years_on_twitter + .001),
    ff_ratio = (followers_count + 1) / (friends_count + followers_count + 1)
  )
  dplyr::bind_cols(x, description_df, name_df, location_df)
}

