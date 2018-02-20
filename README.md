
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
  "ma_salmon", "juliasilge", "tidyversetweets", 
  "American__Voter", "mothgenerator", "hrbrmstr")

## get botornot estimates
data <- botornot(users)

## arrange by prob ests
data[order(data$prob_bot), ]
## # A tibble: 11 x 2
##    user            prob_bot
##    <chr>              <dbl>
##  1 realDonaldTrump  0.00728
##  2 hadleywickham    0.0290 
##  3 juliasilge       0.103  
##  4 hrbrmstr         0.206  
##  5 kearneymw        0.215  
##  6 dataandme        0.289  
##  7 ma_salmon        0.397  
##  8 tidyversetweets  0.972  
##  9 mothgenerator    0.984  
## 10 American__Voter  0.991  
## 11 netflix_bot      0.994
```
