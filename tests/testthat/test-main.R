context("tweetbotornot")

test_that("default (with tweets) works", {

  ## select users
  users <- c("realdonaldtrump", "netflix_bot",
    "kearneymw", "dataandme", "hadleywickham",
    "ma_salmon", "juliasilge", "tidyversetweets",
    "American__Voter", "mothgenerator", "hrbrmstr")

  ## if local, get new data
  pat <- Sys.getenv("TWITTER_PAT")
  if (!identical(pat, "") && file.exists(pat)) {
    ## get botornot estimates
    p <- tweetbotornot(users)
  } else {
    data <- readRDS("test-data.rds")
    p <- tweetbotornot(data)
  }
  expect_true(is.data.frame(p))
  expect_equal(nrow(p), 11)

  ## this time with botornot
  if (!identical(pat, "") && file.exists(pat)) {
    ## get botornot estimates
    p <- botornot(users)
  } else {
    data <- readRDS("test-data.rds")
    p <- botornot(data)
  }
  expect_equal(nrow(p), 11)
  expect_true(is.data.frame(p))
})


test_that("fast (w/o tweets) works", {

  ## select users
  users <- c("realdonaldtrump", "netflix_bot",
    "kearneymw", "dataandme", "hadleywickham",
    "ma_salmon", "juliasilge", "tidyversetweets",
    "American__Voter", "mothgenerator", "hrbrmstr")

  ## if local, get new data
  pat <- Sys.getenv("TWITTER_PAT")
  if (!identical(pat, "") && file.exists(pat)) {
    ## get botornot estimates
    p <- tweetbotornot(users, fast = TRUE)
  } else {
    data <- readRDS("test-data.rds")
    p <- tweetbotornot(data, fast = TRUE)
  }
  expect_true(is.data.frame(p))
  expect_equal(nrow(p), 11)

  ## this time with botornot
  if (!identical(pat, "") && file.exists(pat)) {
    ## get botornot estimates
    p <- botornot(users, fast = TRUE)
  } else {
    data <- readRDS("test-data.rds")
    p <- botornot(data, fast = TRUE)
  }
  expect_equal(nrow(p), 11)
  expect_true(is.data.frame(p))
})
