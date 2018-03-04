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
  tibble::as_tibble(unique(merge(tweets, users, by = "user_id")),
    validate = FALSE)
}
