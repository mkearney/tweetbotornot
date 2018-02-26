
dataandme %>%
  mutate(
    created_at = utc_time(created_at),
    day = difftime(created_at, min(created_at), units = "days"),
    day = as.integer(day),
    timeofday = timeofday(created_at)) %>%
  select(created_at, day, timeofday, since_last) %>%
  mutate(weekday = factor(as.integer(timeofday), labels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))) %>%
  ggplot(aes(x = 24 * (timeofday - as.integer(timeofday)),
    y = since_last,
    fill = weekday)) +
  geom_point(shape = 21, alpha = .7, size = 2.5) +
  labs(title = "Tweet timestamp patterns of @dataandme",
    subtitle = "Broken down by minutes since previous tweet and day of the week",
    x = "Hour of Day", y = "Minutes Since") +
  theme_mwk() +
  facet_wrap(~ weekday,
    scales = "free_x", nrow = 2) +
  scale_x_continuous(breaks = c(0, 6, 12, 18, 24)) +
  theme(legend.position = "none") +
  ggsave("~/Desktop/dataandmepatterns.png")


dataandme %>%
  mutate(timeofday = timeofday(created_at)) %>%
  ggplot(aes(x = timeofday, y = since_last)) +
  geom_line()
