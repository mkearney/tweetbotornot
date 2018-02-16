## read in the data (train and test)
##
trn <- rtweet::lookup_users(botornot_train$user_id)
tst <- rtweet::lookup_users(botornot_test$user_id)

botornot_train <- trn
botornot_test <- tst
save(botornot_train, file = "data/botornot_train.rda")
save(botornot_test, file = "data/botornot_test.rda")

trn$bot <- botornot_train$bot[match(trn$user_id, botornot_train$user_id)]
tst$bot <- botornot_test$bot[match(tst$user_id, botornot_test$user_id)]

ftrain <- extract_features(trn)
ftest <- extract_features(tst)


## apply function to training and test data sets
ftrain <- extract_features(botornot_train)
ftest <- extract_features(botornot_test)

save(ftrain, file = "data/ftrain.rda")
save(ftest, file = "data/fterst.rda")

botornot_model <- train_model(rbind(ftrain, ftest))

save(botornot_model, file = "data/botornot_model.rda")

percent_correct(ftrain, botornot_model)
percent_correct(ftest, botornot_model)

library(botornot)
users <- c("realdonaldtrump", "netflix_bot",
  "kearneymw", "dataandme", "hadleywickham",
  "ma_salmon", "juliasilge", "tidyversetweets")
data <- botornot(users)
data[order(data$prob_bot), ]

data.frame(levels(data$user), data$prob_bot)

Sys.getenv("TWITTER_PAT")
readRenviron("~/.Renviron")
