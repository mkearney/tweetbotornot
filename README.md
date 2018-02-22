
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

There's one function `botornot()`. Give it a vector of screen names, user IDs, or data frames returned by [rtweet](http://rtweet.info).

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

    > # A tibble: 11 x 2
    >    user            prob_bot
    >    <chr>              <dbl>
    >  1 realDonaldTrump  0.00431
    >  2 hadleywickham    0.0178 
    >  3 juliasilge       0.0897 
    >  4 ma_salmon        0.220  
    >  5 dataandme        0.225  
    >  6 kearneymw        0.238  
    >  7 hrbrmstr         0.443  
    >  8 netflix_bot      0.971  
    >  9 tidyversetweets  0.979  
    > 10 American__Voter  0.985  
    > 11 mothgenerator    0.989
