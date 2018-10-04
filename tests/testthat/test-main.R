context("tweetbotornot")

test_that("default (with tweets) works", {
  ## select users
  users <- c("realdonaldtrump", "netflix_bot",
    "kearneymw", "dataandme", "hadleywickham",
    "ma_salmon", "juliasilge", "tidyversetweets",
    "American__Voter", "mothgenerator", "hrbrmstr")

  ## get botornot estimates
  data <- tweetbotornot(users)
  expect_true(is.data.frame(data))
  expect_equal(nrow(data), 11)
  data <- tweetbotornot(users)
  expect_equal(nrow(data), 11)
  expect_true(is.data.frame(data))
})


test_that("fast (w/o tweets) works", {
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
