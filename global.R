library(shiny)
library(shinyjs)
library(ggplot2)
library(tidyr)
library(scales)

# Labels for items
item_names <- paste0("Item_", 1:5)
item_text <- c(
  "I feel more energized after exercising.",
  "I make time to exercise even when I'm busy.",
  "I enjoy exercising in my free time.",
  "I feel guilty when I skip a workout.",
  "Exercising is one of my top priorities."
)

# Default parameters
a_default <- rep(1.0, 5)
b_default <- seq(-2, 2, length.out = 5)  # base difficulty for each item
c_default <- rep(0.2, 5)

# Define UM palette
um_colors <- c("maize" = "#FFCB05", 
               "blue" = "#00274C",
               "red" = "#9A3324",
               "orange"= "#D86018",
               "teal" = "#00B2A9",
               "purple" = "#702082", 
               "ash" = "#989C97",
               "stone" = "#655A52")  