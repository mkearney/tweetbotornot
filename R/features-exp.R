extract_features_exp <- function(x) {
  ## remove retweet text and counts
  x$text[x$is_retweet] <- NA_character_
  x$retweet_count[x$is_retweet] <- NA_integer_

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
    ) %>%
    dplyr::ungroup()
  x <- x[names(x) != "n"]
  x
}
