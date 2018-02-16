
botornot
--------

An R package for classifying Twitter accounts as `bot` or `not_bot`.

Install
-------

Install from Github

``` r
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::install_github("mkearney/botornot")
```

Usage
-----

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
## 3 realDonaldTrump 0.006464292
## 5       kearneymw 0.080821327
## 2      juliasilge 0.081998433
## 4       ma_salmon 0.087341763
## 6       dataandme 0.482836007
## 1     netflix_bot 0.982314113
## 8 tidyversetweets 0.983468770
```
