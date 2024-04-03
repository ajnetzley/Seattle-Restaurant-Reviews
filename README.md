# Seattle-Restaurant-Reviews

# Abstract:
This study explores online restaurant reviews in Seattle by analyzing data collected from Tripadvisor, Yelp, and Google. Relationships between rating and review count, cuisine type, platform, and neighborhood were analyzed via a suite of point and interval inferential procedures and statistical tests, including t-test, ANOVA, chi-square, and linear regression. We found that less-reviewed restaurants had a greater proportion of highly-rated restaurants on some platforms, possibly indicating overrating. We also found that ratings and rating distributions of top rated restaurants differed significantly by review platform. While Seattle lacks a definitive top cuisine, we discovered that it does have top neighborhoods, with certain areas consistently receiving higher ratings than others. We also discovered that review count and star rating were significant predictors for a restaurant’s Tripadvisor ranking. These findings suggest diners should be cautious of highly-rated restaurants with few reviews, consider the source of a rating, and explore neighborhood trends before putting too much stock in an online score.

# Introduction:
When in an unfamiliar city and hungry, it’s common to let online restaurant reviews guide your choice of where to eat. Oftentimes, this strategy pays off, and well-reviewed locations serve amazing food. However, online ratings depend on a variety of factors that can move the goalposts and lead to misleading scores. Compared to other cities, Seattle seems especially problematic in this regard. Therefore, our group set out to address these difficulties and improve our decision-making as diners using data from top review platforms.
In particular, after scraping and merging our cross-platform dataset, our group broke our efforts out into individual lines of questioning. These questions are listed below:

How does review count affect rating trustworthiness?
Are certain cuisines rated significantly higher than others? 
Is there a bias related to reviews platform? 
Is there a difference in restaurant rating and price by neighborhood?
Can Tripadvisor restaurant rankings be predicted using a regression model?

# Methods – Data description: 
In order to address our research questions, we needed up-to-date Seattle area restaurant rating data. Unfortunately, this data was not readily available on public forums, so we chose to build our own dataset by scraping popular reviews sites. We began by scraping the top 3500 King County restaurants from Tripadvisor. We then used name and address information to scrape corresponding data from Yelp and Google, creating a cross-platform restaurant ratings dataset. Technologies used to accomplish this task include beautifulsoup, Selenium, and selected browser extensions.
We then preprocessed, joined, and cleaned our data to create one unified dataset. Cleaning steps included removing nans, dropping duplicates, standardizing column names and text format, filtering to relevant columns, and selecting only restaurants in Seattle. To merge the data, we used fuzzy matching of the name, zip code and street name. The final dataset contained 1357 restaurants with 24 attributes. This dataset became our shared source of data for the analyses to follow. For each restaurant, our final dataset contained the restaurant name, address, neighborhood, tags (restaurant and cuisine types), rating, number of reviews, rating distributions, and cost categorization, all by platform.
We note that this data is observational in nature, and may be thought of as the aggregation of voluntary survey results. Therefore, our analysis may be considered an observational study. Users of review platforms elect to review restaurants of their own accord, with no monetary incentives. As a result, non-response bias is apparent in our data. In our analysis, we note that mean restaurant ratings are quite high, and that restaurant ratings distributions are negatively skewed.

# Repository Details
This repository contains three subfolders with data and code:

1.) data
    Data contains all of the raw and processed data files from the webscraping, cleaning, and merging

2.) preprocessing
    Preprocessing contains two notebooks, one that loads and cleans each raw data file, and another that merges the three cleaned data files together.

3.) analysis
    Analysis contains a few notebooks containing the statistical analysis code for the specific questions we answered in this analysis.
