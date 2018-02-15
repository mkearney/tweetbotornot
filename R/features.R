


train_data <- function() botornot$train
test_data <- function() botornot$test

## feature extraction

## is double
is_num <- function(x) is.numeric(x) | is.integer(x)

## parse names and cross ref with SSA
sex_matches <- function(x) {
  nm <- trimws(x$name)
  nm <- gsub("^mr\\.?\\s|^mrs\\.?\\s|^dr\\.?\\s", "", nm,
    ignore.case = TRUE)
  nm <- tolower(trimws(nm))
  nm <- gsub("\\s.*", "", nm)
  x$f <- sex_est_f(nm)
  x$m <- sex_est_m(nm)
  x$fm <- x$f + x$m
  x$fp <- ifelse(x$f == 0, 0, x$f / (x$f + x$m))
  x
}

sex_est_f <- function(x) {
  sex_est_f_ <- function(x) {
    nms <- genderdata::ssa_state$name
    if (!x %in% nms) {
      return(NA_real_)
    }
    sum(genderdata::ssa_state$F[nms == x], na.rm = TRUE)
  }
  vapply(x, sex_est_f_, FUN.VALUE = double(1), USE.NAMES = FALSE)
}

sex_est_m <- function(x) {
  sex_est_m_ <- function(x) {
    nms <- genderdata::ssa_state$name
    if (!x %in% nms) {
      return(NA_real_)
    }
    sum(genderdata::ssa_state$M[nms == x], na.rm = TRUE)
  }
  vapply(x, sex_est_m_, FUN.VALUE = double(1), USE.NAMES = FALSE)
}


extract_features <- function(data) {
  data <- sex_matches(data)
  ## mutate 9 total features
  data <- dplyr::mutate(data,
      ## your new variables should go below here
      bio_chars = nchar(description),
      loc_chars = nchar(location),
      verified = as.integer(verified),
      years = as.integer(difftime(Sys.time(), account_created_at, "days")) / 365,
      ## i added one here so it wouldn't return NaN or undefined values (0 / x)
      tweets_to_followers = (statuses_count + 1) / (followers_count + 1),
      statuses_rate = statuses_count / years,
      ## i added one here so it wouldn't return NaN or undefined values (0 / x)
      ff_ratio = (followers_count + 1) / (friends_count + followers_count + 1))
  ## return only numeric variables
  data[vap_lgl(data, ~ is.numeric(.) | is.integer(.)) | names(data) == "user_id"]
}


train_model <- function(data, n_trees = 1000) {
  ## set params and run model (~ . means use all other variables)
  gbm::gbm(bot ~ .,
    data = data,
    n.trees = n_trees,
    interaction.depth = 5,
    cv.folds = 3,
    verbose = FALSE,
    distribution = "bernoulli",
    n.minobsinnode = 10,
    shrinkage = .04)
}


## write a function to print out the percent correct (overall; for bots, and for non-bots)
percent_correct <- function(data, m, n_trees = 500) {
  data$pred <- predict(m, newdata = data, n.trees = n_trees, type = "response")
  x <- table(correct = data$pred > .5, bot = data$bot)
  pc <- round((x[2, 2]) / sum(x[, 2]), 4)
  pc <- as.character(pc * 100)
  message(sprintf("The model was %s%% accurate when classifying bots.\n", pc))
  pc <- round((x[1, 1]) / sum(x[, 1]), 4)
  pc <- as.character(pc * 100)
  message(sprintf("The model was %s%% accurate when classifying non-bots.\n", pc))
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
  gbm::predict.gbm(botornot_model, n.trees = 500, newdata = x, type = "response")
}
