library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(rpart)				       
library(rattle)					
library(rpart.plot)				
library(RColorBrewer)				
library(party)					
library(partykit)				
library(caret)
library(stringr)
library(RCurl)
library(rvest)
library(magrittr)
library(splitstackshape)
library(AggregateR)
library(Hmisc)

##Loading in the data from the team github page
data <- read.csv("https://raw.githubusercontent.com/mikeasilva/data-scientist-skills/master/ds%20skills%20-%20cleaning%20-%20categorized_skills.csv", header = TRUE)

#add up and consolidate any matching rows
#add up the rows that match
data <- aggregate(count~clean_skill + Period.Table.Group, data=data, FUN=sum)



#Build a Word Cloud
# Install
# install.packages("tm")  # for text mining
# install.packages("SnowballC") # for text stemming
# install.packages("wordcloud") # word-cloud generator 
# install.packages("RColorBrewer") # color palettes
# Load
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")


#defining the list for the loop to run off of
#see all the periodic table groups
data.groups <- unique(data$Period.Table.Group)
data.groups <- as.list(data.groups)

unique(data$Period.Table.Group)


#lets do a loop
for (i in 1:length(data.groups)){
  
data <- filter(data, data$Period.Table.Group == data.groups[[i]])


# Build a General Word Cloud
set.seed(1234)
wordcloud(words = data$clean_skill, freq = data$count, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

##Loading in the data from the team github page
data <- read.csv("https://raw.githubusercontent.com/mikeasilva/data-scientist-skills/master/ds%20skills%20-%20cleaning%20-%20categorized_skills.csv", header = TRUE)

#add up and consolidate any matching rows
#add up the rows that match
data <- aggregate(count~clean_skill + Period.Table.Group, data=data, FUN=sum)

}

# Build a General Word Cloud
set.seed(1234)
wordcloud(words = data$clean_skill, freq = data$count, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

#Filter
data <- filter(data, data$count > 15)
data <- arrange(data, data$count)


#Bar Graph with Gradient Applied
ggplot(data=data,aes(reorder(data$clean_skill, data$count), data$count)) + 
  geom_col(aes(fill = data$count)) + 
  scale_fill_gradient2(low = "white", 
                       high = "blue", 
                       midpoint = median(data$count)) + 
  coord_flip() + 
  labs(x = "Skill", y = "Count", title = "Data Science Skills", subtitle = "Mined from Job Listings")

