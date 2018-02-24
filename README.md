
botornot
--------

An R package for classifying Twitter accounts as `bot or not`.

Features
--------

Uses machine learning to classify Twitter accounts as bots or not bots. The model is 92.56% accurate when classifying bots and 92.03% accurate when classifying non-bots.

Overall, the model is correct 92.2% of the time.

Install
-------

Install from Github.

``` r
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::install_github("mkearney/botornot")
```

Usage
-----

There's one function `botornot()`. Give it a vector of screen names or user IDs and let it go to work.

``` r
## load package
library(botornot)

## select users
users <- c("realdonaldtrump", "netflix_bot",
  "kearneymw", "dataandme", "hadleywickham",
  "ma_salmon", "juliasilge", "tidyversetweets", 
  "American__Voter", "mothgenerator", "hrbrmstr")

## get botornot estimates
data <- botornot(users)

## arrange by prob ests
data[order(data$prob_bot), ]
```

    # # A tibble: 11 x 2
    #    user            prob_bot
    #    <chr>              <dbl>
    #  1 realDonaldTrump  0.00382
    #  2 hadleywickham    0.0483 
    #  3 juliasilge       0.0859 
    #  4 ma_salmon        0.186  
    #  5 dataandme        0.233  
    #  6 kearneymw        0.278  
    #  7 hrbrmstr         0.433  
    #  8 netflix_bot      0.971  
    #  9 tidyversetweets  0.979  
    # 10 American__Voter  0.987  
    # 11 mothgenerator    0.995

### Integration with rtweet

The `botornot()` function also accepts data returned by [rtweet](http://rtweet.info) functions.

``` r
## load rtweet
library(rtweet)

## get most recent 100 tweets from each user
tmls <- get_timelines(users, n = 100)

## pass the returned data to botornot()
data <- botornot(tmls)

## arrange by prob ests
data[order(data$prob_bot), ]
```

    # # A tibble: 11 x 2
    #    user            prob_bot
    #    <chr>              <dbl>
    #  1 realDonaldTrump  0.00382
    #  2 hadleywickham    0.0483 
    #  3 juliasilge       0.0859 
    #  4 ma_salmon        0.186  
    #  5 dataandme        0.233  
    #  6 kearneymw        0.278  
    #  7 hrbrmstr         0.433  
    #  8 netflix_bot      0.971  
    #  9 tidyversetweets  0.979  
    # 10 American__Voter  0.987  
    # 11 mothgenerator    0.995

### `fast = TRUE`

The default \[gradient boosted\] model uses both users-level (bio, location, number of followers and friends, etc.) **and** tweets-level (number of hashtags, mentions, capital letters, etc. in a user's most recent 100 tweets) data to estimate the probability that users are bots. For larger data sets, this method can be quite slow. Due to Twitter's REST API rate limits, users are limited to only 180 estimates per every 15 minutes.

To maximize the number of estimates per 15 minutes (at the cost of being less accurate), use the `fast = TRUE` argument. This method uses **only** users-level data, which increases the maximum number of estimates per 15 minutes to *90,000*! Due to losses in accuracy, this method should be used with caution!

``` r
## get botornot estimates
data <- botornot(users, fast = TRUE)

## arrange by prob ests
data[order(data$prob_bot), ]
```

    # # A tibble: 11 x 2
    #    user            prob_bot
    #    <chr>              <dbl>
    #  1 realDonaldTrump   0.0119
    #  2 hadleywickham     0.0159
    #  3 juliasilge        0.184 
    #  4 ma_salmon         0.274 
    #  5 hrbrmstr          0.393 
    #  6 kearneymw         0.467 
    #  7 dataandme         0.490 
    #  8 netflix_bot       0.988 
    #  9 mothgenerator     0.993 
    # 10 tidyversetweets   0.993 
    # 11 American__Voter   0.996
