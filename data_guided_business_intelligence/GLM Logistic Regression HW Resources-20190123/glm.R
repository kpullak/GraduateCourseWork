install.packages("readxl")
install.packages("dummies")
install.packages("caTools")
install.packages("reshape")
library('dummies')
library("readxl")
library('caTools')
library(dplyr)
library(tidyr)
library(reshape)

addClusters <- function(pivot_table) {
  pivot_table_rows <- dim(pivot_table)[1]
  pivot_table['parent'] <- pivot_table[1]
  for(i in 1:(pivot_table_rows-1)){
    for(j in (i+1):pivot_table_rows){
      if(abs(pivot_table[i,2] - pivot_table[j,2]) < 0.05){
        pivot_table[j, 'parent'] <- pivot_table[i, 'parent']
      } 
    }
  }
  return (pivot_table)
}

replaceChildValues <- function(original_df, parentTable, coloum) {
  rows_df = dim(original_df)[1]
  rows_parent = dim(parentTable)[1] 
  for(i in 1:rows_df){
    for(j in 1:rows_parent){
      if(parentTable[j, coloum] == original_df[i, coloum]){
        original_df[i, coloum] = parentTable[j, 'parent']
      }
    }
  }
  
  return (original_df)
}

currentDir <- getwd()
setwd(currentDir)

eBayAuctionData <- read_excel("eBayAuctions.xls")

ebay_melt <- melt(eBayAuctionData, measure.vars = "Competitive?")
ebay_castCategory <- cast(ebay_melt, Category  ~ variable , mean)
ebay_castCurrency <- cast(ebay_melt, currency  ~ variable , mean)
ebay_castDuration <- cast(ebay_melt, Duration  ~ variable , mean)
ebay_castEndDay <- cast(ebay_melt, endDay  ~ variable , mean)

ebay_castCategoryParent = addClusters(ebay_castCategory)
ebay_castCurrencyParent = addClusters(ebay_castCurrency)
ebay_castDurationParent = addClusters(ebay_castDuration)
ebay_castEndDayParent = addClusters(ebay_castEndDay)

eBayAuctionData <- replaceChildValues(eBayAuctionData, ebay_castCategoryParent, 'Category')
eBayAuctionData <- replaceChildValues(eBayAuctionData, ebay_castCurrencyParent, 'currency')
eBayAuctionData <- replaceChildValues(eBayAuctionData, ebay_castDurationParent, 'Duration')
eBayAuctionData <- replaceChildValues(eBayAuctionData, ebay_castEndDayParent, 'endDay')

eBayAuctionData$Category <- as.factor(eBayAuctionData$Category)
eBayAuctionData$currency <- as.factor(eBayAuctionData$currency)
eBayAuctionData$Duration <- as.factor(eBayAuctionData$Duration)
eBayAuctionData$endDay <- as.factor(eBayAuctionData$endDay)

eBayAuctionDataDummy <- dummy_cols(eBayAuctionData)
eBayAuctionDataDummy <- eBayAuctionDataDummy[ , -which(names(eBayAuctionDataDummy) 
                        %in% c("Category","currency", "Duration", "endDay"))]
View(eBayAuctionDataDummy)

set.seed(123)
eBayAuctionDataDummy$spl=sample.split(eBayAuctionDataDummy$OpenPrice, SplitRatio=0.6)
head(eBayAuctionDataDummy)
train=subset(eBayAuctionDataDummy,spl==TRUE) 
test=subset(eBayAuctionDataDummy,spl==FALSE)

logit.fit = glm(`Competitive?` ~ ., data = train, family = "binomial")
logit.fit$coefficients
summary(logit)