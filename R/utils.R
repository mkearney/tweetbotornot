
join_rtweet <- function(x) {
  if (!is.data.frame(x) || (nrow(x) == 0 &&
      (NROW(attr(x, "users")) == 0) &&
      (NROW(attr(x, "tweets")) == 0))) {
    return(data.frame())
  }
  if ("users" %in% names(attributes(x))) {
    tw <- as_tbl(x)
    ## get users data
    us <- as_tbl(attr(tw, "users"))
    ## they should be same length; if so fill in user rows w/o tweets
    if (NROW(tw) == NROW(us)) {
      tw$user_id[is.na(tw$user_id)] <- us$user_id[is.na(tw$user_id)]
      tw$screen_name[is.na(tw$screen_name)] <- us$screen_name[is.na(tw$screen_name)]
    }
    ## if users data is empty, create NA-filled users data for tw$user_id
    if (NROW(us) == 0) {
      us <- as_tbl(data.frame(
        list(tw$user_id, as.list(rep(NA, length(usercols_())))),
        stringsAsFactors = FALSE, check.rows = FALSE, check.names = FALSE,
        row.names = NULL))
      names(us) <- names(usercols_())
      ## if tweets data is empty, create NA-filled tweets data for us$user_id
    } else if (NROW(tw) == 0) {
      tw <- as_tbl(data.frame(
        list(us$user_id, as.list(rep(NA, length(statuscols_())))),
        stringsAsFactors = FALSE, check.rows = FALSE, check.names = FALSE,
        row.names = NULL))
      names(tw) <- names(statuscols_())
      if (NROW(tw) == NROW(us)) {
        tw$user_id[is.na(tw$user_id)] <- us$user_id[is.na(tw$user_id)]
        tw$screen_name[is.na(tw$screen_name)] <- us$screen_name[is.na(tw$screen_name)]
      }
      ## if any us$users are not in tw$users
    } else if (any(!us$user_id %in% tw$user_id)) {
      tw2 <- as_tbl(data.frame(
        list(as.list(rep(NA, 2)),
          unique(us$user_id[!us$user_id %in% tw$user_id]),
          as.list(rep(NA, length(statuscols_()) - 3))),
        stringsAsFactors = FALSE, check.rows = FALSE, check.names = FALSE,
        row.names = NULL))
      names(tw2) <- names(statuscols_())
      tw <- rbind(tw, tw2)
    }
    ## remove screen name
    us <- us[, names(us) != "screen_name"]
    ## remove duplicate user rows
    us <- us[!duplicated(us$user_id), ]
    ## merge tweets and users data
    x <- merge(tw, us, by = "user_id")
    ## remove duplicate tweet rows
    x <- as_tbl(x[!(duplicated(x$status_id) & !is.na(x$status_id)), ])
  } else if ("tweets" %in% names(attributes(x))) {
    us <- as_tbl(x)
    ## get tweets data
    tw <- as_tbl(attr(us, "tweets"))
    ## they should be same length; if so fill in user rows w/o tweets
    if (NROW(tw) == NROW(us)) {
      tw$user_id[is.na(tw$user_id)] <- us$user_id[is.na(tw$user_id)]
      tw$screen_name[is.na(tw$screen_name)] <- us$screen_name[is.na(tw$screen_name)]
    }
    ## if tweets data is empty, create NA-filled tweets data for us$user_id
    if (NROW(tw) == 0) {
      tw <- as_tbl(data.frame(
        list(us$user_id, as.list(rep(NA, length(usercols_())))),
        stringsAsFactors = FALSE, check.rows = FALSE, check.names = FALSE,
        row.names = NULL))
      names(tw) <- names(usercols_())
      ## if users data is empty, create NA-filled users data for tw$user_id
    } else if (NROW(us) == 0) {
      us <- as_tbl(data.frame(
        list(tw$user_id, as.list(rep(NA, length(statuscols_())))),
        stringsAsFactors = FALSE, check.rows = FALSE, check.names = FALSE,
        row.names = NULL))
      names(us) <- names(statuscols_())
      ## if any us$users are not in tw$users
    } else if (any(!us$user_id %in% tw$user_id)) {
      tw2 <- as_tbl(data.frame(list(
        unique(us$user_id[!us$user_id %in% tw$user_id]),
        as.list(rep(NA, length(statuscols_()) - 1))),
        stringsAsFactors = FALSE, check.rows = FALSE, check.names = FALSE,
        row.names = NULL))
      names(tw2) <- names(statuscols_())
      tw <- rbind(tw, tw2)
    }
    ## remove screen name
    us <- us[, names(us) != "screen_name"]
    ## remove duplicate user rows
    us <- us[!duplicated(us$user_id), ]
    ## merge tweets and users data
    x <- merge(tw, us, by = "user_id")
    ## remove duplicate tweet rows
    x <- as_tbl(x[!(duplicated(x$status_id) & !is.na(x$status_id)), ])
  }
  ## arrange newest to oldest
  #if (any(!is.na(x$created_at))) {
  #  x <- x[order(x$created_at, decreasing = TRUE), ]
  #}
  ## return merged data frame
  x
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
    "favorite_count", "hashtags") %in% names(x), na.rm = TRUE)
  num_users <- sum(c("name", "followers_count", "favourites_count", "friends_count",
    "account_created_at", "description") %in% names(x), na.rm = TRUE)
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


hourofweekday <- function(x) {
  h <- as.numeric(substr(x, 12, 13))
  m <- as.numeric(substr(x, 15, 16)) / 60
  hms <- round(timeofday(x), 0)
  wd <- format(x, "%a")
  wd <- as.integer(factor(
    wd, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))) * 24
  (wd + hms) / 24
}

timeofday <- function(x) {
  h <- as.numeric(substr(x, 12, 13))
  m <- as.numeric(substr(x, 15, 16)) / 60
  s <- as.numeric(substr(x, 18, 19)) / 360
  h + m + s
}
count_mean <- function(x) {
  if (length(x) == 1L && is.na(x)) return(NA_real_)
  x <- table(x)
  x <- as.integer(x) - 1L
  mean(x, na.rm = TRUE)
}
