


train_data <- function() botornot$train
test_data <- function() botornot$test

## feature extraction

## is double
is_num <- function(x) is.numeric(x) | is.integer(x)

## parse names and cross ref with SSA
# sex_matches <- function(x) {
#   nm <- trimws(x$name)
#   nm <- gsub("^mr\\.?\\s|^mrs\\.?\\s|^dr\\.?\\s", "", nm,
#     ignore.case = TRUE)
#   nm <- tolower(trimws(nm))
#   nm <- gsub("\\s.*", "", nm)
#   x$f <- sex_est_f(nm)
#   x$m <- sex_est_m(nm)
#   x$fm <- x$f + x$m
#   x$fp <- ifelse(x$f == 0, 0, x$f / (x$f + x$m))
#   x
# }
#
# sex_est_f <- function(x) {
#   sex_est_f_ <- function(x) {
#     nms <- genderdata::ssa_state$name
#     if (!x %in% nms) {
#       return(NA_real_)
#     }
#     sum(genderdata::ssa_state$F[nms == x], na.rm = TRUE)
#   }
#   vapply(x, sex_est_f_, FUN.VALUE = double(1), USE.NAMES = FALSE)
# }

# sex_est_m <- function(x) {
#   sex_est_m_ <- function(x) {
#     nms <- genderdata::ssa_state$name
#     if (!x %in% nms) {
#       return(NA_real_)
#     }
#     sum(genderdata::ssa_state$M[nms == x], na.rm = TRUE)
#   }
#   vapply(x, sex_est_m_, FUN.VALUE = double(1), USE.NAMES = FALSE)
# }

n_words <- function(x) {
  x <- gsub("\\d", "", x)
  x <- strsplit(x, "\\s+")
  lengths(x)
}

n_digits <- function(x) {
  nchar(gsub("\\D", "", x))
}

n_hashtags <- function(x) {
  m <- gregexpr("#\\S+", x)
  m <- regmatches(x, m)
  lengths(m)
}

n_mentions <- function(x) {
  m <- gregexpr("@\\S+", x)
  m <- regmatches(x, m)
  lengths(m)
}

n_commas <- function(x) {
  m <- gregexpr(",+", x)
  m <- regmatches(x, m)
  lengths(m)
}

n_caps <- function(x) {
  m <- gregexpr("[A-Z]", x)
  m <- regmatches(x, m)
  lengths(m)
}

extract_features <- function(data) {
  data <- rtweet_join(data)
  ##data <- sex_matches(data)
  ## mutate 9 total features
  data <- dplyr::mutate(data,
    ## your new variables should go below here
    has_tweet = as.integer(is.na(text)),
    tweet_chars = ifelse(is.na(text), 0, nchar(text)),
    bio_chars = nchar(description),
    bio_hts = n_hashtags(description),
    bio_sns = n_mentions(description),
    bio_caps = n_caps(description),
    loc_chars = nchar(location),
    loc_commas = n_commas(location),
    name_chars = nchar(name),
    name_words = n_words(name),
    name_caps = n_caps(name),
    sn_digits = n_digits(screen_name),
    verified = as.integer(verified),
    years = as.integer(
      difftime(Sys.time(), account_created_at, "days")) / 365,
    created_at = as.POSIXct(ifelse(is.na(created_at), mean(created_at, na.rm = TRUE),
      created_at), origin = "1970-01-01", tz = "UTC"),
    weeks = as.integer(
      difftime(Sys.time(), created_at, "days")) / 7,
    ## i added one here so it wouldn't return NaN or undefined values (0 / x)
    tweets_to_followers = (statuses_count + 1) / (followers_count + 1),
    statuses_rate = statuses_count / years,
    ## i added one here so it wouldn't return NaN or undefined values (0 / x)
    ff_ratio = (followers_count + 1) / (friends_count + followers_count + 1))
  ## return only numeric variables
  data[vap_lgl(data,
    ~ is.numeric(.) | is.integer(.)) | names(data) == "user_id"]
}


train_model <- function(data, n_trees = 1000) {
  data <- data[!vap_lgl(data, ~ all(is.na(.)) || any(lengths(.) != 1L))]
  data <- data[vap_lgl(data, ~ is.numeric(.) | is.integer(.))]
  ## set params and run model (~ . means use all other variables)
  gbm::gbm(bot ~ .,
    data = data,
    n.trees = n_trees,
    interaction.depth = 3,
    cv.folds = 3,
    bag.fraction = .5,
    train.fraction = 1.0,
    verbose = FALSE,
    distribution = "bernoulli",
    n.minobsinnode = 5,
    shrinkage = .075,
    n.cores = 2L)
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
