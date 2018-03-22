context("botrnot.R")

test_that("botrnot", {
  ## select users
  users <- c("realdonaldtrump", "netflix_bot",
    "kearneymw", "dataandme", "hadleywickham",
    "ma_salmon", "juliasilge", "tidyversetweets",
    "American__Voter", "mothgenerator", "hrbrmstr")

  ## get botornot estimates
  data <- botornot(users)
  expect_true(is.data.frame(data))
  data <- botornot(users, fast = TRUE)
  expect_true(is.data.frame(data))
})
