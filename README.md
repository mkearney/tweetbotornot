
botornot
--------

An R package for classifying Twitter accounts as `bot or not`.

Features
--------

Uses machine learning to classify Twitter accounts as bots or not bots. The model is 90% accurate when classifying bots, and 92% accurate when classifying non-bots.

Overall, the model is correct 91% of the time.

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
  "ma_salmon", "juliasilge", "tidyversetweets")

## get botornot estimates
data <- botornot(users)

## arrange by prob ests
data[order(data$prob_bot), ]
## # A tibble: 8 x 2
##   user            prob_bot
##   <chr>              <dbl>
## 1 realDonaldTrump  0.00728
## 2 hadleywickham    0.0290 
## 3 juliasilge       0.103  
## 4 kearneymw        0.215  
## 5 dataandme        0.289  
## 6 ma_salmon        0.397  
## 7 tidyversetweets  0.972  
## 8 netflix_bot      0.994
```
