# Professional R Plots Demonstration
# Using stock market and financial data
# This script demonstrates best practices for creating publication-quality plots in R

# Install required packages (uncomment if needed)
# install.packages(c("ggplot2", "tidyquant", "quantmod", "dplyr", "lubridate", "gridExtra", "scales"))

library(ggplot2)
library(tidyquant)
library(dplyr)
library(lubridate)
library(gridExtra)
library(scales)

# ============================================================================
# 1. SETTING UP PROFESSIONAL PLOT THEME
# ============================================================================

# Create a reusable professional theme
theme_professional <- function() {
  theme_minimal() +
  theme(
    # Text elements
    plot.title = element_text(
      size = 14,
      face = "bold",
      hjust = 0.5,
      margin = margin(b = 10)
    ),
    plot.subtitle = element_text(
      size = 11,
      hjust = 0.5,
      color = "gray40",
      margin = margin(b = 10)
    ),
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 10),
    legend.position = "right",

    # Panel elements
    panel.grid.major = element_line(color = "gray90", size = 0.3),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),

    # Margins
    plot.margin = margin(15, 15, 15, 15),

    # Remove axis lines for cleaner look
    axis.line = element_blank()
  )
}

# ============================================================================
# 2. DOWNLOAD STOCK DATA
# ============================================================================

# Fetch stock data for multiple companies (2020-2024)
stocks <- c("AAPL", "MSFT", "GOOGL", "TSLA")

stock_data <- tq_get(stocks,
                     get = "stock.prices",
                     from = "2022-01-01",
                     to = "2024-12-31")

# View the data structure
head(stock_data)

# ============================================================================
# 3. EXAMPLE 1: TIME SERIES PLOT - SINGLE STOCK PRICE
# ============================================================================

apple_data <- stock_data %>% filter(symbol == "AAPL")

plot1 <- ggplot(apple_data, aes(x = date, y = close)) +
  geom_line(color = "#1f77b4", size = 0.8) +
  geom_area(fill = "#1f77b4", alpha = 0.1) +
  labs(
    title = "Apple Inc. Stock Price",
    subtitle = "Daily closing price (2022-2024)",
    x = "Date",
    y = "Price ($)",
    caption = "Data source: Yahoo Finance"
  ) +
  scale_y_continuous(labels = dollar) +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_professional() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(plot1)

# ============================================================================
# 4. EXAMPLE 2: COMPARATIVE TIME SERIES - MULTIPLE STOCKS
# ============================================================================

# Normalize prices to percentage change from start date
normalized_data <- stock_data %>%
  group_by(symbol) %>%
  mutate(
    start_price = first(close),
    pct_change = ((close - start_price) / start_price) * 100
  ) %>%
  ungroup()

plot2 <- ggplot(normalized_data, aes(x = date, y = pct_change, color = symbol)) +
  geom_line(size = 0.9) +
  labs(
    title = "Stock Performance Comparison",
    subtitle = "Percentage change from start date (2022-2024)",
    x = "Date",
    y = "Return (%)",
    color = "Symbol",
    caption = "Data source: Yahoo Finance"
  ) +
  scale_color_brewer(palette = "Set1") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_professional() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(~symbol, scales = "free_y", nrow = 2)

print(plot2)

# ============================================================================
# 5. EXAMPLE 3: CANDLESTICK CHART
# ============================================================================

# Create candlestick chart for Apple (monthly data)
apple_monthly <- apple_data %>%
  mutate(
    year_month = floor_date(date, "month"),
    week_num = week(date)
  ) %>%
  group_by(year_month) %>%
  summarise(
    open = first(open),
    high = max(high),
    low = min(low),
    close = last(close),
    .groups = 'drop'
  ) %>%
  mutate(
    direction = ifelse(close >= open, "up", "down"),
    x = row_number()
  )

plot3 <- ggplot(apple_monthly, aes(x = x)) +
  geom_segment(aes(xend = x, y = low, yend = high),
               color = "black", size = 0.3) +
  geom_rect(aes(xmin = x - 0.3, xmax = x + 0.3,
                ymin = pmin(open, close),
                ymax = pmax(open, close),
                fill = direction),
            color = "black", size = 0.5) +
  scale_fill_manual(
    values = c("up" = "#2ecc71", "down" = "#e74c3c"),
    labels = c("up" = "Close Up", "down" = "Close Down"),
    name = "Direction"
  ) +
  labs(
    title = "Apple Inc. Monthly Candlestick Chart",
    subtitle = "High, low, open, and close prices",
    x = "Month",
    y = "Price ($)",
    caption = "Data source: Yahoo Finance"
  ) +
  theme_professional() +
  theme(axis.text.x = element_blank())

print(plot3)

# ============================================================================
# 6. EXAMPLE 4: VOLUME ANALYSIS
# ============================================================================

# Select recent data for clarity
recent_apple <- apple_data %>%
  filter(date >= "2024-01-01") %>%
  mutate(price_change = close - open)

plot4 <- ggplot(recent_apple, aes(x = date, y = volume, fill = price_change > 0)) +
  geom_col() +
  scale_fill_manual(
    values = c("TRUE" = "#2ecc71", "FALSE" = "#e74c3c"),
    labels = c("TRUE" = "Price Up", "FALSE" = "Price Down"),
    name = "Daily Change"
  ) +
  labs(
    title = "Apple Inc. Trading Volume",
    subtitle = "Daily volume with price direction indicator (2024)",
    x = "Date",
    y = "Volume",
    caption = "Data source: Yahoo Finance"
  ) +
  scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6)) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  theme_professional() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(plot4)

# ============================================================================
# 7. EXAMPLE 5: SCATTER PLOT - PRICE VS VOLUME CORRELATION
# ============================================================================

recent_all_stocks <- stock_data %>%
  filter(date >= "2024-01-01")

plot5 <- ggplot(recent_all_stocks, aes(x = volume, y = close, color = symbol)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = FALSE, alpha = 0.3, size = 0.8) +
  facet_wrap(~symbol, scales = "free") +
  scale_color_brewer(palette = "Set1") +
  scale_x_continuous(labels = unit_format(unit = "M", scale = 1e-6)) +
  scale_y_continuous(labels = dollar) +
  labs(
    title = "Price vs Volume Relationship",
    subtitle = "Scatter plot with linear trend (2024)",
    x = "Volume (Millions)",
    y = "Closing Price ($)",
    color = "Symbol",
    caption = "Data source: Yahoo Finance"
  ) +
  theme_professional() +
  theme(legend.position = "none")

print(plot5)

# ============================================================================
# 8. EXAMPLE 6: BOX PLOT - PRICE DISTRIBUTION
# ============================================================================

recent_quarterly <- stock_data %>%
  filter(date >= "2023-01-01") %>%
  mutate(quarter = quarter(date, with_year = TRUE))

plot6 <- ggplot(recent_quarterly, aes(x = quarter, y = close, fill = symbol)) +
  geom_boxplot(alpha = 0.7, outlier.size = 1.5) +
  facet_wrap(~symbol, scales = "free_y", nrow = 2) +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous(labels = dollar) +
  labs(
    title = "Stock Price Distribution by Quarter",
    subtitle = "Box plot showing median, quartiles, and outliers",
    x = "Quarter",
    y = "Closing Price ($)",
    fill = "Symbol",
    caption = "Data source: Yahoo Finance"
  ) +
  theme_professional() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )

print(plot6)

# ============================================================================
# 9. EXAMPLE 7: HEATMAP - CORRELATION MATRIX
# ============================================================================

# Calculate daily returns
returns_data <- stock_data %>%
  group_by(symbol) %>%
  arrange(date) %>%
  mutate(daily_return = (close - lag(close)) / lag(close) * 100) %>%
  ungroup() %>%
  select(symbol, date, daily_return) %>%
  pivot_wider(names_from = symbol, values_from = daily_return) %>%
  select(-date)

# Calculate correlation matrix
correlation_matrix <- cor(returns_data, use = "complete.obs")

# Prepare data for heatmap
heatmap_data <- as.data.frame(as.table(correlation_matrix)) %>%
  rename(Symbol1 = Var1, Symbol2 = Var2, Correlation = Freq)

plot7 <- ggplot(heatmap_data, aes(x = Symbol1, y = Symbol2, fill = Correlation)) +
  geom_tile(color = "white", size = 0.5) +
  geom_text(aes(label = round(Correlation, 2)),
            color = "white", size = 4, fontface = "bold") +
  scale_fill_gradient2(
    low = "#d73027",
    mid = "white",
    high = "#1a9850",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  labs(
    title = "Stock Returns Correlation Matrix",
    subtitle = "Pearson correlation of daily returns",
    x = "Stock Symbol",
    y = "Stock Symbol",
    fill = "Correlation",
    caption = "Data source: Yahoo Finance"
  ) +
  theme_professional() +
  theme(
    axis.text = element_text(size = 11),
    aspect.ratio = 1
  )

print(plot7)

# ============================================================================
# 10. EXAMPLE 8: DASHBOARD - COMBINING MULTIPLE PLOTS
# ============================================================================

# Create smaller versions for dashboard
apple_recent <- apple_data %>% filter(date >= "2024-01-01")

dashboard_plot1 <- ggplot(apple_recent, aes(x = date, y = close)) +
  geom_line(color = "#1f77b4", size = 0.7) +
  labs(title = "Price Trend", x = NULL, y = "Price ($)") +
  scale_y_continuous(labels = dollar) +
  theme_professional() +
  theme(plot.title = element_text(size = 12))

dashboard_plot2 <- ggplot(apple_recent, aes(x = date, y = volume)) +
  geom_col(fill = "#ff7f0e", alpha = 0.7) +
  labs(title = "Trading Volume", x = NULL, y = "Volume") +
  scale_y_continuous(labels = unit_format(unit = "M", scale = 1e-6)) +
  theme_professional() +
  theme(plot.title = element_text(size = 12))

dashboard_plot3 <- ggplot(apple_recent, aes(x = date, y = (close - lag(close))/lag(close)*100)) +
  geom_col(aes(fill = (close - lag(close))/lag(close)*100 > 0)) +
  scale_fill_manual(values = c("TRUE" = "#2ecc71", "FALSE" = "#e74c3c")) +
  labs(title = "Daily Returns (%)", x = NULL, y = "Return (%)") +
  theme_professional() +
  theme(legend.position = "none", plot.title = element_text(size = 12))

# Combine plots into a dashboard
dashboard <- gridExtra::grid.arrange(
  dashboard_plot1,
  dashboard_plot2,
  dashboard_plot3,
  ncol = 1,
  top = "Apple Inc. Performance Dashboard (2024)"
)

print(dashboard)

# ============================================================================
# KEY TAKEAWAYS FOR PROFESSIONAL PLOTS
# ============================================================================
#
# 1. CONSISTENCY: Use a custom theme function for all plots
# 2. COLORS: Use color-blind friendly palettes (RColorBrewer)
# 3. LABELS: Always include clear titles, subtitles, axis labels, and captions
# 4. SCALING: Format axes appropriately (dollar signs, millions, percentages)
# 5. MARGINS: Use adequate white space and margins
# 6. FACETING: Use facet_wrap() for comparing multiple categories
# 7. TYPOGRAPHY: Use appropriate font sizes and weights
# 8. GRID: Use subtle gridlines for readability
# 9. SAVE: Use high-resolution PNG or PDF for publications
# 10. SIMPLICITY: Remove unnecessary elements (chartjunk)

# ============================================================================
# SAVING PLOTS
# ============================================================================

# Save individual plots at high resolution
# ggsave("plot_name.png", width = 10, height = 6, dpi = 300)
# ggsave("plot_name.pdf", width = 10, height = 6)

# Example:
# ggsave("/home/user/Coursera_Capstone/apple_stock_price.png", plot1, width = 10, height = 6, dpi = 300)
