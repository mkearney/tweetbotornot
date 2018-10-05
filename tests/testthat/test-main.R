context("tweetbotornot")

test_that("default (with tweets) works", {
  skip_on_cran()
  token <- readRDS("twitter_tokens")
  saveRDS(token, "twitter_api_token.rds")
  Sys.setenv(TWITTER_PAT = "twitter_api_token.rds")
  on.exit(unlink("twitter_api_token.rds"))
  ## select users
  users <- c("realdonaldtrump", "netflix_bot",
    "kearneymw", "dataandme", "hadleywickham",
    "ma_salmon", "juliasilge", "tidyversetweets",
    "American__Voter", "mothgenerator", "hrbrmstr")

  ## get botornot estimates
  data <- tweetbotornot(users)
  expect_true(is.data.frame(data))
  expect_equal(nrow(data), 11)
  data <- botornot(users)
  expect_equal(nrow(data), 11)
  expect_true(is.data.frame(data))
})


test_that("fast (w/o tweets) works", {
  skip_on_cran()
  token <- readRDS("twitter_tokens")
  saveRDS(token, "twitter_api_token.rds")
  Sys.setenv(TWITTER_PAT = "twitter_api_token.rds")
  on.exit(unlink("twitter_api_token.rds"))
  ## select users
  users <- c("realdonaldtrump", "netflix_bot",
    "kearneymw", "dataandme", "hadleywickham",
    "ma_salmon", "juliasilge", "tidyversetweets",
    "American__Voter", "mothgenerator", "hrbrmstr")

  ## get botornot estimates
  data <- tweetbotornot(users, fast = TRUE)
  expect_equal(nrow(data), 11)
  expect_true(is.data.frame(data))
  data <- botornot(users, fast = TRUE)
  expect_equal(nrow(data), 11)
  expect_true(is.data.frame(data))
})
