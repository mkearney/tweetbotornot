#' retweet_join
#'
#' @param x Data returned by rtweet function to be merged (users and tweets)
#' @return A single tibble with both users and tweets data
#' @export
rtweet_join <- function(x) UseMethod("rtweet_join")

#' @export
rtweet_join.data.frame <- function(x) {
  tub <- tw_or_usr(x)
  if (tub == "tweets") {
    users <- attr(x, "users")
    if (is.null(users)) users <- data.frame()
    tweets <- x
  } else if (tub == "users") {
    tweets <- attr(x, "tweets")
    if (is.null(tweets)) tweets <- data.frame()
    users <- x
  } else if (tub == "both") {
    x <- convert_factors(x)
    return(x)
  }
  users <- convert_factors(users)
  tweets <- convert_factors(tweets)
  if (nrow(users) == 0) {
    return(tweets)
  }
  if (nrow(tweets) == 0) {
    return(users)
  }
  un <- names(users)
  tn <- names(tweets)
  if ("screen_name" %in% un && "screen_name" %in% tn) {
    tweets <- tweets[, names(tweets) != "screen_name"]
    tn <- names(tweets)
  }
  if ("lang" %in% un && "lang" %in% tn) {
    names(users)[names(users) == "lang"] <- "account_lang"
    un <- names(users)
  }
  if ("created_at" %in% un && "created_at" %in% tn) {
    names(users)[names(users) == "created_at"] <- "account_created_at"
    un <- names(users)
  }
  if (any(tn %in% un[un != "user_id"])) {
    tweets <- tweets[!tn %in% un[un != "user_id"]]
  }
  tibble::as_tibble(merge(tweets, users, by = "user_id"),
    validate = FALSE)
}

convert_factors <- function(x) {
  fcts <- vap_lgl(x, is.factor)
  if (sum(fcts) == 0L) {
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
    "favorite_count", "hashtags") %in% names(x))
  num_users <- sum(c("name", "followers_count", "favourites_count",
    "friends_count", "account_created_at", "description") %in% names(x))
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
