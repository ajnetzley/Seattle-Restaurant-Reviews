# Jake Flynn
# Final Project
# Seattle Restaurant Analysis

# Required libraries

library(tidyverse)
library(ggplot2)
library(dplyr)
library(stats)


# Data Cleaning

set.seed(557)
data <- read.csv("CompleteRestaurantDataClean.csv")

# Create an average restaurant rating across all three platforms
agg_data <- data %>%
  rowwise() %>%
  mutate(Average_Rating = mean(c(Rating_google, Rating_tripadvisor, Rating_yelp), na.rm = TRUE)) %>%
  ungroup()

# Standardize TripAdvisor prices
agg_data$Price_TripAdvisor_Numeric <- ifelse(agg_data$Cost_tripadvisor == "$", 1,
                                             ifelse(agg_data$Cost_tripadvisor == "$$ - $$$", 2.5,
                                                    ifelse(agg_data$Cost_tripadvisor == "$$$$", 4, NA)))

# Standardize Yelp prices
agg_data$Price_Yelp_Numeric <- ifelse(agg_data$Cost_yelp == "$", 1,
                                      ifelse(agg_data$Cost_yelp == "$$", 2,
                                             ifelse(agg_data$Cost_yelp == "$$$", 3,
                                                    ifelse(agg_data$Cost_yelp == "$$$$", 4, NA))))

# Handle missing or unusual values (assigning NA) for prices
agg_data$Price_Yelp_Numeric[agg_data$Cost_yelp == "Unclaimed" | agg_data$Cost_yelp == ""] <- NA
agg_data$Price_TripAdvisor_Numeric[agg_data$Cost_tripadvisor == ""] <- NA

# Calculate average price for each restaurant across Yelp and Trip Advisor
agg_data$Average_Price <- rowMeans(agg_data[,c("Price_TripAdvisor_Numeric", "Price_Yelp_Numeric")], na.rm = TRUE)

# Count the number of restaurants that have a value in the Average Rating column
num_not_null_rating = sum(!is.na(agg_data$Average_Rating))
print(num_not_null_rating)
# Count the number of restaurants that have a value in the price column
num_not_null_price = sum(!is.na(agg_data$Average_Price))
print(num_not_null_price)
# Count the number of restaurants that have a value in the Trip Advisor price column
num_not_null_tripadvisor = sum(!is.na(agg_data$Price_TripAdvisor_Numeric))
print(num_not_null_tripadvisor)
# Count the number of restaurants that have a value in the Yelp price column
num_not_null_yelp = sum(!is.na(agg_data$Price_Yelp_Numeric))
print(num_not_null_yelp)


# Test if there are significant differences in the average restaurant ratings across
# different neighborhoods

# Boxplots of average rating by neighborhood (assess equal variance assumption for ANOVA)
avg_rating_by_neighborhood <- ggplot(agg_data, aes(x = Neighborhood_yelp, y = Average_Rating)) +
                              geom_boxplot() +
                              theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(avg_rating_by_neighborhood)

# Count the number of restaurants in each neighborhood
restaurant_counts <- agg_data %>%
  group_by(Neighborhood_yelp) %>%
  summarise(Count = n())
print(restaurant_counts)

# Create qq plots to assess the normality of ratings by neighborhood
ratings_hist <- ggplot(agg_data, aes(sample = Average_Rating)) + 
  geom_qq() + 
  geom_qq_line() + 
  facet_wrap(~ Neighborhood_yelp) + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(ratings_hist)

# Calculate confidence intervals for each neighborhood (Average Rating)
neighborhoods <- unique(agg_data$Neighborhood_yelp)
ci_df <- data.frame(Neighborhood = character(),
                    Lower_Bound = numeric(),
                    Average_Rating = numeric(),
                    Upper_Bound = numeric(),
                    Sample_Size = integer(),
                    T_Statistic = numeric(),
                    Standard_Deviation = numeric(),
                    stringsAsFactors = FALSE)
for (neighborhood in neighborhoods) {
  # Filter data for the current neighborhood
  neighborhood_data <- subset(agg_data, Neighborhood_yelp == neighborhood)
  
  # Calculate the 95% confidence interval for the mean rating of the current neighborhood using Welch's t-test
  ci <- t.test(neighborhood_data$Average_Rating, var.equal = FALSE)$conf.int
  t <- t.test(neighborhood_data$Average_Rating, var.equal = FALSE)$statistic
  p <- t.test(neighborhood_data$Average_Rating, var.equal = FALSE)$p.value
  
  ci_df <- rbind(ci_df, data.frame(Neighborhood = neighborhood,
                                   Lower_Bound = round(ci[1], 3),
                                   Average_Rating = round(mean(neighborhood_data$Average_Rating), 3),
                                   Upper_Bound = round(ci[2], 3),
                                   Sample_Size = nrow(neighborhood_data),
                                   T_Statistic = round(t, 3),
                                   Standard_Deviation = round(sd(neighborhood_data$Average_Rating), 3)))
}
print(ci_df)

# Display confidence intervals for each neighborhood
ci_plot <- ggplot(ci_df, aes(x = Neighborhood, y = (Lower_Bound + Upper_Bound) / 2, ymin = Lower_Bound, ymax = Upper_Bound)) +
  geom_pointrange() +
  coord_flip() +
  labs(title = "95% Confidence Intervals for Average Ratings by Neighborhood",
       x = "Neighborhood",
       y = "Average Rating") +
  theme_minimal()
print(ci_plot)

# Proceed with ANOVA for Average Restaurant rating
anova_result <- aov(Average_Rating ~ Neighborhood_yelp, data = agg_data)
summary_anova_result <- summary(anova_result)

# Pairwise T-tests With Bonferroni Correction

post_hoc_result <- pairwise.t.test(agg_data$Average_Rating, agg_data$Neighborhood_yelp,
                                   p.adjust.method = "bonferroni", pool.sd=FALSE)
p_values <- post_hoc_result$p.value

# Find pairs with significant differences
significant_pairs <- which(p_values < 0.05, arr.ind = TRUE)

# Store significant pairs and their p-values
significant_results_df <- data.frame(Neighborhood1 = character(),
                                     Neighborhood2 = character(),
                                     P_Value = numeric(),
                                     AverageRatingDifference = numeric(),
                                     stringsAsFactors = FALSE)
if(length(significant_pairs) > 0) {
  for (i in 1:nrow(significant_pairs)) {
    row <- significant_pairs[i, 1]
    col <- significant_pairs[i, 2]
    new_row <- data.frame(Neighborhood1 = rownames(p_values)[row],
                          Neighborhood2 = colnames(p_values)[col],
                          P_Value = round(p_values[row, col], 3),
                          AverageRatingDifference = round(
                            mean(subset(agg_data, Neighborhood_yelp == colnames(p_values)[col])$Average_Rating) - 
                              mean(subset(agg_data, Neighborhood_yelp == rownames(p_values)[row])$Average_Rating), 3))
    significant_results_df <- rbind(significant_results_df, new_row)
  }
}
print(significant_results_df)


# Assess whether there are statistical differences in price within the neighborhoods
# with significant differences in average restaurant rating

significant_neighborhoods <- c("Queen Anne/South Lake Union", "Capitol Hill", "Fremont/Wallingford", "University District")
filtered_data <- agg_data[agg_data$Neighborhood_yelp %in% significant_neighborhoods, ]

# Create Q-Q plots to assess normality
qq_price <- ggplot(filtered_data, aes(sample = Average_Price)) + 
  geom_qq() + 
  geom_qq_line() + 
  facet_wrap(~Neighborhood_yelp)
print(qq_price)

# Boxplots of average rating by neighborhood for filtered_data (assess equal variance assumption for ANOVA)
avg_rating_by_neighborhood_filtered <- ggplot(filtered_data, aes(x = Neighborhood_yelp, y = Average_Price)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(avg_rating_by_neighborhood_filtered)

# Count the number of restaurants in each neighborhood for filtered_data
restaurant_counts_price <- filtered_data %>%
  group_by(Neighborhood_yelp) %>%
  summarise(Count = n())
print(restaurant_counts_price)

# Perform ANOVA on the filtered data to compare average prices across the significant neighborhoods
anova_result_price <- aov(Average_Price ~ Neighborhood_yelp, data = filtered_data)
summary_anova_result_price <- summary(anova_result_price)

# Pairwise T-tests With Bonferroni Correction

post_hoc_result_price <- pairwise.t.test(filtered_data$Average_Price, filtered_data$Neighborhood_yelp,
                                   p.adjust.method = "bonferroni", pool.sd=FALSE)
p_values_price <- post_hoc_result_price$p.value

# Find pairs with significant differences
significant_pairs_price <- which(p_values_price < 0.05, arr.ind = TRUE)

# Store significant pairs and their p-values
significant_results_df_price <- data.frame(Neighborhood1 = character(),
                                     Neighborhood2 = character(),
                                     P_Value = numeric(),
                                     AveragePriceDifference = numeric(),
                                     stringsAsFactors = FALSE)
if(length(significant_pairs_price) > 0) {
  for (i in 1:nrow(significant_pairs_price)) {
    row <- significant_pairs_price[i, 1]
    col <- significant_pairs_price[i, 2]
    new_row <- data.frame(Neighborhood1 = rownames(p_values_price)[row],
                          Neighborhood2 = colnames(p_values_price)[col],
                          P_Value = round(p_values_price[row, col], 4),
                          AveragePriceDifference = round(
                            mean(subset(filtered_data, Neighborhood_yelp == colnames(p_values_price)[col])$Average_Price, na.rm = TRUE) -
                              mean(subset(filtered_data, Neighborhood_yelp == rownames(p_values_price)[row])$Average_Price, na.rm = TRUE), 3))
    significant_results_df_price <- rbind(significant_results_df_price, new_row)
  }
}
print(significant_results_df_price)
