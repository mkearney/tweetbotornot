extract_features_exp <- function(x) {
  nrc_langs <- which_language(x$lang)
  text <- tokenizers::tokenize_tweets(x$text)
  x$sent_nrc_positive <- sentiment_nrc_positive(text, nrc_langs)
  x$sent_nrc_negative <- sentiment_nrc_negative(text, nrc_langs)
  x$sent_nrc_anger <- sentiment_nrc_anger(text, nrc_langs)
  x$sent_nrc_anticipation <- sentiment_nrc_anticipation(text, nrc_langs)
  x$sent_nrc_disgust <- sentiment_nrc_disgust(text, nrc_langs)
  x$sent_nrc_fear <- sentiment_nrc_fear(text, nrc_langs)
  x$sent_nrc_sadness <- sentiment_nrc_sadness(text, nrc_langs)
  x$sent_nrc_surprise <- sentiment_nrc_surprise(text, nrc_langs)
  x$sent_nrc_trust <- sentiment_nrc_trust(text, nrc_langs)

  ## remove retweet text and counts
  x$text[x$is_retweet] <- NA_character_
  x$retweet_count[x$is_retweet] <- NA_integer_

  x <- x %>%
    dplyr::group_by(user_id) %>%
    dplyr::summarise(
      ## tweets features
      n_sincelast = count_mean(since_last(.data$created_at)),
      n_timeofday = count_mean(hourofweekday(.data$created_at)),
      n_timeofday = range_(hourofweekday(.data$created_at)),
      n = dplyr::n(),
      n_retweets = sum_(.data$is_retweet),
      n_quotes = sum_(.data$is_quote),
      n_langs = tfse::n_uq(.data$lang),
      retweet_count = mean_(c(0, .data$retweet_count)),
      favorite_count = mean_(c(0, .data$favorite_count)),
      n_tweets = sum_(!.data$is_retweet & !.data$is_quote),
      n_places = sum_(!is.na(.data$place_name)),
      n_geo_coords = ncoord(.data$geo_coords),
      n_bbox_coords = ncoord(.data$bbox_coords),

      sent_nrc_positive_sd = sd_(c(.data$sent_nrc_positive)),
      sent_nrc_negative_sd = sd_(c(.data$sent_nrc_negative)),
      sent_nrc_anger_sd = sd_(c(.data$sent_nrc_anger)),
      sent_nrc_anticipation_sd = sd_(c(.data$sent_nrc_anticipation)),
      sent_nrc_disgust_sd = sd_(c(.data$sent_nrc_disgust)),
      sent_nrc_fear_sd = sd_(c(.data$sent_nrc_fear)),
      sent_nrc_sadness_sd = sd_(c(.data$sent_nrc_sadness)),
      sent_nrc_trust_sd = sd_(c(.data$sent_nrc_trust)),

      sent_nrc_positive_range = range_(c(.data$sent_nrc_positive)),
      sent_nrc_negative_range = range_(c(.data$sent_nrc_negative)),
      sent_nrc_anger_range = range_(c(.data$sent_nrc_anger)),
      sent_nrc_anticipation_range = range_(c(.data$sent_nrc_anticipation)),
      sent_nrc_disgust_range = range_(c(.data$sent_nrc_disgust)),
      sent_nrc_fear_range = range_(c(.data$sent_nrc_fear)),
      sent_nrc_sadness_range = range_(c(.data$sent_nrc_sadness)),
      sent_nrc_trust_range = range_(c(.data$sent_nrc_trust)),

      sent_nrc_positive = mean_(c(0, .data$sent_nrc_positive)),
      sent_nrc_negative = mean_(c(0, .data$sent_nrc_negative)),
      sent_nrc_anger = mean_(c(0, .data$sent_nrc_anger)),
      sent_nrc_anticipation = mean_(c(0, .data$sent_nrc_anticipation)),
      sent_nrc_disgust = mean_(c(0, .data$sent_nrc_disgust)),
      sent_nrc_fear = mean_(c(0, .data$sent_nrc_fear)),
      sent_nrc_sadness = mean_(c(0, .data$sent_nrc_sadness)),
      sent_nrc_trust = mean_(c(0, .data$sent_nrc_trust)),

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
      twitterforblackberry = sum_(
        "Twitter for BlackBerry®" %in% .data$source) / .data$n,
      dlvrit = sum_("dlvr.it" %in% .data$source) / .data$n,
      instagram = sum_("Instagram" %in% .data$source) / .data$n,
      curiouscat = sum_("Curious Cat" %in% .data$source) / .data$n,
      echofon = sum_("Echofon" %in% .data$source) / .data$n,
      ubersocialforblackberry = sum_(
        "UberSocial for BlackBerry" %in% .data$source) / .data$n,
      athkarapp = sum_("athkarApp" %in% .data$source) / .data$n,
      mobilewebm2 = sum_("Mobile Web (M2)" %in% .data$source) / .data$n,
      twitterfeed = sum_("twitterfeed" %in% .data$source) / .data$n,
      tweetbotforios = sum_("Tweetbot for iOS" %in% .data$source) / .data$n,
      tweetcasterforandroid = sum_(
        "TweetCaster for Android" %in% .data$source) / .data$n,
      twitcomcomunidades = sum_(
        "Twitcom - Comunidades " %in% .data$source) / .data$n,
      cloudhopper = sum_("Cloudhopper" %in% .data$source) / .data$n,
      twicca = sum_("twicca" %in% .data$source) / .data$n,
      wordpresscom = sum_("WordPress.com" %in% .data$source) / .data$n,
      mobileweb = sum_("Mobile Web" %in% .data$source) / .data$n,
      foursquare = sum_("Foursquare" %in% .data$source) / .data$n,
      showroomlive = sum_("SHOWROOM-LIVE" %in% .data$source) / .data$n,
      twitterforwebsites = sum_(
        "Twitter for Websites" %in% .data$source) / .data$n,
      ios = sum_("iOS" %in% .data$source) / .data$n,
      tumblr = sum_("Tumblr" %in% .data$source) / .data$n,
      tweetlogix = sum_("Tweetlogix" %in% .data$source) / .data$n,
      socialoomph = sum_("SocialOomph" %in% .data$source) / .data$n,
      buffer = sum_("Buffer" %in% .data$source) / .data$n,
      twitcleplus = sum_("twitcle plus" %in% .data$source) / .data$n,
      keitaiweb = sum_("Keitai Web" %in% .data$source) / .data$n,
      sandaysoftcumulus = sum_(
        "Sandaysoft Cumulus" %in% .data$source) / .data$n,
      twitpaneforandroid = sum_(
        "TwitPane for Android" %in% .data$source) / .data$n,
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
      ubersocialforandroid = sum_(
        "UberSocial for Android" %in% .data$source) / .data$n,
      janetterforandroid = sum_(
        "Janetter for Android" %in% .data$source) / .data$n,
      twitterforandroidtablets = sum_(
        "Twitter for Android Tablets" %in% .data$source) / .data$n,
      twitterformac = sum_("Twitter for Mac" %in% .data$source) / .data$n,

      ## users features
      lang_und = as.integer(.data$account_lang[1] == "und"),
      lang_tr = as.integer(.data$account_lang[1] == "tr"),
      lang_ru = as.integer(.data$account_lang[1] == "ru"),
      lang_pt = as.integer(.data$account_lang[1] == "pt"),
      lang_ja = as.integer(.data$account_lang[1] == "ja"),
      lang_in = as.integer(.data$account_lang[1] == "in"),
      lang_fr = as.integer(.data$account_lang[1] == "fr"),
      lang_es = as.integer(.data$account_lang[1] == "es"),
      lang_en = as.integer(.data$account_lang[1] == "en"),
      lang_are = as.integer(.data$account_lang[1] == "ar"),
      lang_de = as.integer(.data$account_lang[1] == "de"),
      lang_it = as.integer(.data$account_lang[1] == "it"),
      lang_id = as.integer(.data$account_lang[1] == "id"),
      lang_ko = as.integer(.data$account_lang[1] == "ko"),
      lang_nl = as.integer(.data$account_lang[1] == "nl"),
      lang_hi = as.integer(.data$account_lang[1] == "hi"),
      lang_fil = as.integer(.data$account_lang[1] == "fil"),
      lang_th = as.integer(.data$account_lang[1] == "th"),
      lang_engb = as.integer(.data$account_lang[1] == "en-gb"),
      screen_name_alpha = nchar_(.data$screen_name[1]),
      screen_name_num = ndigit_(.data$screen_name[1]),

      prof_image_na = as.integer(grepl("default_profile_images", .data$profile_image_url[1])),
      prof_image_type = as.integer(grepl("\\.jpg", .data$profile_image_url[1])),

      profile_bg_na = as.integer(is.na(.data$profile_background_url[1])),
      profile_bg_type = as.integer(grepl("\\.png", .data$profile_background_url[1])),

      profile_bn_na = as.integer(is.na(.data$profile_banner_url[1])),

      verified = as.integer(.data$verified[1]),
      profile_url = as.integer(!is.na(.data$profile_url[1])),
      years_on_twitter = relative_twitter_age(.data$account_created_at[1]),
      tweets_per_year = .data$n_tweets / (1 + .data$years_on_twitter),
      statuses_count = max_(c(0, .data$statuses_count)),
      followers_count = max_(c(0, .data$followers_count)),
      friends_count = max_(c(0, .data$friends_count)),
      listed_count = max_(c(0, .data$listed_count)),
      favourites_count = max_(c(0, .data$favourites_count)),
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
  years <- as.numeric(difftime(
    Sys.time(), account_created_at, units = "days"))/365
  aot <- age_of_twitter()
  ## set it at 15
  (years / aot) * 15
}

ncoord <- function(x) {
  sum(vapply(x, function(.x) !is.na(.x[1]), integer(1), USE.NAMES = FALSE))
}


code_langs <- c(
  english = "en",
  arabic = "ar",
  basque = "eu",
  bengali = "bn",
  catalan = "ca",
  chinese_simplified = "zh",
  chinese_traditional = "zh",
  danish = "da",
  dutch = "nl",
  esperanto = "eo",
  finnish = "fi",
  french = "fr",
  german = "de",
  greek = "el",
  gujarati = "gu",
  hebrew = "he",
  hindi = "hi",
  irish = "en-gb",
  italian = "it",
  japanese = "ja",
  latin = "la",
  marathi = "mr",
  persian = "fa",
  portuguese = "pt",
  romanian = "ro",
  russian = "ru",
  somali = "so",
  spanish = "es",
  sudanese = "su",
  swahili = "sw",
  swedish = "sv",
  tamil = "ta",
  telugu = "te",
  thai = "th",
  turkish = "tr",
  ukranian = "uk",
  urdu = "ur",
  vietnamese = "vi",
  welsh = "cy",
  yiddish = "yi",
  zulu = "zu"
)


which_language <- function(lang) {
  ifelse(lang %in% code_langs,
    names(code_langs)[match(lang, code_langs)],
    "english")
}



sentiment_est_binary <- function(x, lang, dict) {
  if (is.character(x)) {
    x <- gsub("https?://\\S+|@\\S+", "", x)
    x <- tokenizers::tokenize_words(
      x, lowercase = TRUE, strip_punct = TRUE, strip_numeric = FALSE
    )
  }
  unlist(
    Map(function(.x, .y)
      sum(.x %in% dict$word[dict$language == .y]),
      x, lang, USE.NAMES = FALSE)
  )
}



sentiment_nrc_positive <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "positive", ]
  )
}
sentiment_nrc_negative <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "negative", ]
  )
}
sentiment_nrc_anger <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "anger", ]
  )
}
sentiment_nrc_anticipation <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "anticipation", ]
  )
}
sentiment_nrc_disgust <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "disgust", ]
  )
}
sentiment_nrc_fear <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "fear", ]
  )
}
sentiment_nrc_sadness <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "sadness", ]
  )
}
sentiment_nrc_surprise <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "surprise", ]
  )
}
sentiment_nrc_trust <- function(x, lang) {
  sentiment_est_binary(x, lang,
    nrc_dict[nrc_dict$sentiment == "trust", ]
  )
}
