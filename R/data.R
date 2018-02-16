#' botornot data
#'
#' This data comes from accounts identified as probable-bots and probable-not
#' bots. The data are user-level features of real Twitter accounts. All features
#' were derived from data gathered from Twitter's REST API on 2017-02-15. The
#' variables are...
#'
#' @section Variables:
#'
#' \itemize{
#'   \item `id`: anonymized user ID
#'   \item `bot`: Non-bots coded as 0 and bots coded as 1
#'   \item `friends_count`: Number of friends (followed by user)
#'   \item `followers_count`: Number of followers (following user)
#'   \item `ff_ratio`: Friends / friends + followers
#'   \item `statuses_count`: Number of statuses posted by users
#'   \item `listed_count`: Number of lists user appears on
#'   \item `account_age`: Years since joining Twitter
#'   \item `bio_chars`: Number of characters in user bio
#'   \item `bio_hashtags`: Number of hashtags in user bio
#'   \item `bio_mentions`: Number of mentions in user bio
#'   \item `loc_chars`: Number of characters in user location
#'   \item `has_url`: Whether (1) or not (0) user has listed a URL
#'   \item `verified`: Whether (1) or not (0) user is verified
#'   \item `name_chars`: Number of chars in user name
#'   \item `name_names`: Number of names in user name
#'   \item `last_tweet`: Months since user's last tweet
#' }
#'
#' @docType data
#' @name botornot_data
#' @format Tibbles with 20 variables.
#' @examples
#' botornot_train
#' botornot_test
"botornot_train"

#' @rdname botornot_data
"botornot_test"

#' botornot model
#'
#' The model used to generate predicted probabilities.
#'
#' @docType data
#' @name botornot_model
#' @format A gbm model object
#' @examples
#' botornot_model
"botornot_model"
