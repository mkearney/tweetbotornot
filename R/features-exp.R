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

      iphone = sum_("Twitter for iPhone" %in% .data$source) / .data$n,
      webclient = sum_("Twitter Web Client" %in% .data$source) / .data$n,
      android = sum_("Twitter for Android" %in% .data$source) / .data$n,
      hootsuite = sum_("Hootsuite" %in% .data$source) / .data$n,
      lite = sum_("Twitter Lite" %in% .data$source) / .data$n,
      ipad = sum_("Twitter for iPad" %in% .data$source) / .data$n,
      google = sum_("Google" %in% .data$source) / .data$n,
      ifttt = sum_("IFTTT" %in% .data$source) / .data$n,
      facebook = sum_("Facebook" %in% .data$source) / .data$n,

      twittbotnet = sum_("twittbot.net" %in% .data$source) / .data$n,
      tweetdeck = sum_("TweetDeck" %in% .data$source) / .data$n,
      twitterforblackberry = sum_("Twitter for BlackBerry®" %in% .data$source) / .data$n,
      dlvrit = sum_("dlvr.it" %in% .data$source) / .data$n,
      instagram = sum_("Instagram" %in% .data$source) / .data$n,
      curiouscat = sum_("Curious Cat" %in% .data$source) / .data$n,
      echofon = sum_("Echofon" %in% .data$source) / .data$n,
      ubersocialforblackberry = sum_("UberSocial for BlackBerry" %in% .data$source) / .data$n,
      athkarapp = sum_("athkarApp" %in% .data$source) / .data$n,
      mobilewebm2 = sum_("Mobile Web (M2)" %in% .data$source) / .data$n,
      twitterfeed = sum_("twitterfeed" %in% .data$source) / .data$n,
      tweetbotforiοs = sum_("Tweetbot for iΟS" %in% .data$source) / .data$n,
      tweetcasterforandroid = sum_("TweetCaster for Android" %in% .data$source) / .data$n,
      twitcomcomunidades = sum_("Twitcom - Comunidades " %in% .data$source) / .data$n,
      cloudhopper = sum_("Cloudhopper" %in% .data$source) / .data$n,
      twicca = sum_("twicca" %in% .data$source) / .data$n,
      wordpresscom = sum_("WordPress.com" %in% .data$source) / .data$n,
      mobileweb = sum_("Mobile Web" %in% .data$source) / .data$n,
      foursquare = sum_("Foursquare" %in% .data$source) / .data$n,
      showroomlive = sum_("SHOWROOM-LIVE" %in% .data$source) / .data$n,
      twitterforwebsites = sum_("Twitter for Websites" %in% .data$source) / .data$n,
      ios = sum_("iOS" %in% .data$source) / .data$n,
      tumblr = sum_("Tumblr" %in% .data$source) / .data$n,
      tweetlogix = sum_("Tweetlogix" %in% .data$source) / .data$n,
      socialoomph = sum_("SocialOomph" %in% .data$source) / .data$n,
      buffer = sum_("Buffer" %in% .data$source) / .data$n,
      twitcleplus = sum_("twitcle plus" %in% .data$source) / .data$n,
      keitaiweb = sum_("Keitai Web" %in% .data$source) / .data$n,
      sandaysoftcumulus = sum_("Sandaysoft Cumulus" %in% .data$source) / .data$n,
      twitpaneforandroid = sum_("TwitPane for Android" %in% .data$source) / .data$n,
      playstationr4 = sum_("PlayStation(R)4" %in% .data$source) / .data$n,
      writelonger = sum_("Write Longer" %in% .data$source) / .data$n,
      featherforios = sum_("feather for iOS  " %in% .data$source) / .data$n,
      askfm = sum_("Ask.fm" %in% .data$source) / .data$n,
      crowdfireinc = sum_("Crowdfire Inc." %in% .data$source) / .data$n,
      thesocialjukebox = sum_("The Social Jukebox" %in% .data$source) / .data$n,
      tween = sum_("Tween" %in% .data$source) / .data$n,
      janetter = sum_("Janetter" %in% .data$source) / .data$n,
      dynamictweets = sum_("Dynamic Tweets" %in% .data$source) / .data$n,
      twitcasting = sum_("TwitCasting" %in% .data$source) / .data$n,
      ubersocialforandroid = sum_("UberSocial for Android" %in% .data$source) / .data$n,
      janetterforandroid = sum_("Janetter for Android" %in% .data$source) / .data$n,
      twitterforandroidtablets = sum_("Twitter for Android Tablets" %in% .data$source) / .data$n,
      twitterformac = sum_("Twitter for Mac" %in% .data$source) / .data$n,

      prof_image_na = sum_(is.na(.data$profile_image_url[1])),
      prof_image_type = sum_(grepl("\\.jpg", .data$profile_image_url[1])),

      profile_bg_na = sum_(is.na(.data$profile_background_url[1])),
      profile_bg_type = sum_(grepl("\\.png", .data$profile_background_url[1])),

      profile_bn_na = sum_(is.na(.data$profile_banner_url[1])),

      verified = as.integer(.data$verified[1]),
      years_on_twitter = relative_twitter_age(.data$account_created_at[1]),
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


age_of_twitter <- function() {
  as.numeric(difftime(Sys.time(), as.POSIXct("2006-03-21"), units = "days"))/365
}

relative_twitter_age <- function(account_created_at) {
  years <- as.numeric(difftime(Sys.time(), account_created_at, units = "days"))/365
  aot <- age_of_twitter()
  ## set it at 15
  (years / aot) * 15
}
