library(tidyverse)

xy_circle <- function(r) {
  theta <- seq(0, 2 * pi, .01)

  # draw the circle
  data.frame(x = r * cos(theta),
    y = r * sin(theta))
}

df_circle <- xy_circle(1)
df_circle$y <- (df_circle$y / 2) + .05
df_triangle <- data.frame(x = 0, y = .6)
df_head1 <- data.frame(
  x = c(-.75, -.75, .75, .75, -.75),
  y = c(-.25, .5, .5, -.25, -.25)
)

df_head2 <- data.frame(
  x = c(-.775, -.775, -.375, -.3, .3, .375, .775, .775),
  y = c(-.25, .05, .05, -.1, -.1, .05, .05, -.25)
)
df_body <- data.frame(
  x = c(-.6, -.6, .6, .6, -.6),
  y = c(-2, -.375, -.375, -2, -2)
)
df_kneck <- data.frame(
  x = c(-.2, -.2, .2, .2),
  y = c(-.375, -.25, -.25, -.375)
)
df_smile <- data.frame(
  x = c(-.3, -.35, .35, .3),
  y = c(-.1, .0, .0, -.1)
)
df_tophead <- data.frame(
  x = c(-.04, -.02, .02, .04),
  y = c(.5, .75, .75, .5)
)
df_toppoint <- xy_circle(.075)
df_toppoint$y <- df_toppoint$y + .75

df_left <- xy_circle(.155)
df_left$y <- df_left$y - .45
df_left$x <- df_left$x - .55

df_right <- xy_circle(.155)
df_right$y <- df_right$y - .45
df_right$x <- df_right$x + .55

df_eyes1 <- data.frame(
  x = c(-.15, .15),
  y = c(.25, .25)
)
df_eyes2 <- data.frame(
  x = c(-.15, .15) * .7,
  y = c(.235, .22)
)



base_color <- "#dddddd"
white <- "#ffffff"
black <- "#222222"
bg <- "darkcyan"

df_larm <- data.frame(
  x = c(-1.3, -.625, -.475, -1.1),
  y = c(-1.25, -.375, -.425, -1.3)
)
df_rarm <- data.frame(
  x = -1 * c(-1.3, -.625, -.475, -1.1),
  y = c(-1.25, -.375, -.425, -1.3)
)
dfhex <- data.frame(
  x = c(0, -1, -1, 0, 0, 1, 1, 0),
  y = c(-1.1, -.6, .43, .93, .93, .43, -.6, -1.1)
)
dfhex <- hexdf(1.15)
size <- .3

p <- ggplot(df_head1, aes(x, y)) +
  geom_polygon(data = dfhex, fill = bg, colour = black, size = 1.25) +
  geom_polygon(data = df_head1, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_head1, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_head2, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_larm, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_rarm, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_left, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_right, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_body, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_kneck, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_smile, fill = white, colour = black, size = size) +
  geom_polygon(data = df_tophead, fill = base_color, colour = black, size = size) +
  geom_polygon(data = df_toppoint, fill = base_color, colour = black, size = size) +
  geom_point(data = df_eyes1, fill = white, colour = black, size = 8, shape = 21) +
  geom_point(data = df_eyes2, size = 2) +
  coord_cartesian(xlim = range(dfhex$x), ylim = range(dfhex$y)) +
  theme_void() +
  theme(legend.position = "none",
    plot.background = element_rect(fill = "transparent", colour = "transparent"),
    panel.background = element_rect(fill = "transparent", colour = "transparent"))

asize <- 3.35
p2 <- p +
  annotate("text", x = -.35, y = -.575, label = "tweet", size = asize,
    family = "Courier New", fontface = "bold", colour = "black") +
  annotate("text", x = -.01, y = -.575, label = "bot", size = asize,
    family = "Courier New", fontface = "bold", colour = "#bb0000") +
  annotate("text", x =  .20, y = -.575, label = "or", size = asize,
    family = "Courier New", fontface = "bold", colour = "#880099") +
  annotate("text", x =  .4125, y = -.575, label = "not", size = asize,
    family = "Courier New", fontface = "bold", colour = "#00aa00")

p2 + hexagon::theme_hexagon() +
  coord_cartesian(xlim = range(dfhex$x), ylim = range(dfhex$y)) +
  ggsave("man/figures/logo.png", width = 1.73, height = 2, units = "in",
    bg = "transparent")
