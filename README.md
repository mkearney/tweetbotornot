
botornot
--------

An R package for classifying Twitter accounts as `bot or not`.

Features
--------

Uses machine learning to classify Twitter accounts as bots or not bots. The model is 89.05% accurate when classifying bots, and 95.98% accurate when classifying non-bots.

Overall, the model is correct 93.4% of the time.

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
##              user    prob_bot
## 3 realDonaldTrump 0.008428412
## 7   hadleywickham 0.127433588
## 2      juliasilge 0.511345270
## 4       ma_salmon 0.641347529
## 5       kearneymw 0.783140171
## 6       dataandme 0.899990681
## 1     netflix_bot 0.979255195
## 8 tidyversetweets 0.996688826
```
