## read in the data (train and test)
botornot_train <- readRDS("data/train.rds")
botornot_test <- readRDS("data/test.rds")
setwd("data")
botornot_train <- tibble::as_tibble(botornot_train)
botornot_test <- tibble::as_tibble(botornot_test)
library(tibble)

save(botornot_train, file = "botornot_train.rda")
save(botornot_test, file = "botornot_test.rda")
devtools::use_build_ignore("make.R")

botornot <- list(train = train, test = test)
setwd("..")
save(botornot, file = "sysdat.rda")

library(magrittr)

## apply function to training and test data sets
ftrain <- extract_features(botornot_train)
rm_.DS_Store()
ftest <- extract_features(botornot_test)


m1 <- train_model(ftrain)

percent_correct(ftrain, m1)

ftest$pred <- predict(m1, newdata = ftest, n.trees = 1000,
  type = "response")
percent_correct(ftest, m1)
