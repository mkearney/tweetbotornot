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
ftest <- extract_features(botornot_test)

save(ftrain, file = "data/ftrain.rda")
save(ftest, file = "data/fterst.rda")

botornot_model2 <- train_model(rbind(ftrain, ftest))
botornot_model <- botornot_model2

save(botornot_model, file = "data/botornot_model.rda")

percent_correct(ftrain, botornot_model)
percent_correct(ftest, botornot_model)

percent_correct(ftrain, botornot_model2)
percent_correct(ftest, botornot_model2)

rt <- rtweet::lookup_users(c("kearneymw", "cstonehoops"))

botornot(c("kearneymw", "cstonehoops", "cnn", "realdonaldtrump"))
