
botornot
--------

An R package for classifying Twitter accounts as `bot or not`.

Features
--------

Uses machine learning to classify Twitter accounts as bots or not bots. The model is 94% accurate. It is slightly better at classifying not bots than classifying bots (low type I error).

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
## 7   hadleywickham 0.005798216
## 3 realDonaldTrump 0.006406957
## 5       kearneymw 0.080821327
## 2      juliasilge 0.093888100
## 4       ma_salmon 0.094190686
## 6       dataandme 0.503423779
## 1     netflix_bot 0.982314113
## 8 tidyversetweets 0.983066201
```
