
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
## identify Twitter users
rt <- rtweet::search_tweets("#rstats", n = 100, include_rts = FALSE)

## supply user IDs (or screen names) to `botornot()` function
rt$pbot <- botornot(rt$user_id)

## for faster results, supply data as returned by 
dplyr::select(rt, screen_name, pbot)
```
