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
data <- read.csv("https://raw.githubusercontent.com/mikeasilva/data-scientist-skills/master/skills_counts.csv", header = TRUE)
raw_skills <- read.csv("https://raw.githubusercontent.com/mikeasilva/data-scientist-skills/master/raw_skills.csv", header = TRUE)
##loading in the csv that I scraped off of wikipedia 
languages <- read.csv("https://raw.githubusercontent.com/crarnouts/CUNY-MSDS/master/Programming_languages.csv", header = TRUE)

####register as a contributor on github

# 
# #converting the raw skills to uppercase
# raw_skills$raw_skills <- toupper(raw_skills$raw_skills)
# data$skill <- toupper(data$skill)
# 
# # #searching for specific key words in the skills columns in the data dataset
# # data$learning <- ifelse(str_detect(data$skill,"learning"), 1, 0)
# # data$data <- ifelse(str_detect(data$skill,"data"), 1, 0)
# # data$math <- ifelse(str_detect(data$skill,"math"), 1, 0)
# # strings <- c("LEARNING", "MATH")
# # data$learning_OR_math <- ifelse(str_detect(data$skill,paste(strings, collapse = "|")), 1, 0)
# # data$languages <- ifelse(str_detect(data$skill,paste(languages_list, collapse = "|")), 1, 0)
# 
# #looking for a specifc set of words in the raw skills dataset
# raw_skills$MATH <- str_count(raw_skills$raw_skills,"MATH")
# raw_skills$LEARNING <- str_count(raw_skills$raw_skills,"LEARNING")
# raw_skills$learning_OR_math_count <- str_count(raw_skills$raw_skills,paste(strings, collapse = "|"))
# 
# #looking to see if programming languages are listed in the job posting and if so how many programming languages
# raw_skills$languages <- ifelse(str_detect(raw_skills$raw_skills,paste(languages_list, collapse = "|")), 1, 0)
# raw_skills$language_count <- str_count(raw_skills$raw_skills,paste(languages_list, collapse = "|"))
# raw_skills$language_count <- str_count(raw_skills$raw_skills,paste(languages_list, collapse = "|"))
# 
# 
# 
# #create a column that is a count of all the strings
# raw_skills$Words <- str_count(raw_skills$raw_skills,",")
# 
# 
# #Thanks @crarnouts! Would you also be willing to clean up the re-capitalization? 
# #I changed everything to lower case so "python" and "Python" would not be listed as two distinct skills. 
# #Also as a heads up there are cases where multiple skills are on one line 
# #(i.e. "nosql (dynamodb/cassandra/mongodb)") . I think we need to break these out into 4 skills NoSQL, MongoDB, etc. 
# 
# #pull in list of programming languages and determine if the row item contains one of those
# 
# #str_detect(payload, paste(strings, collapse = "|")
# 
# 
# 
# # 
# # data$skill <- tolower(data$skill)
# # data_3 <- cSplit(data, "skill", " - ")
# # data_3 <- cSplit(data, "skill", "/")
# # data_3 <- cSplit_l(data, "skill", " - ")
# 
# #using the languages dataset to create a holistic list of all programming language names
# languages_list <- as.character(languages$name)
# #converting all of this programming language names to 
# languages_list <- tolower(languages_list)


#breaking out strings one at a time
data_3 <- cSplit(data, "skill", " - ")
#using the gather function to put skills in the same row
data_4 <- gather(data_3, "skill_num","skill",c(3:14))
data_4 <- data_4[c(1,2,4)]
data_4 <- data_4[!(is.na(data_4$skill) | data_4$skill==""), ]
#second time through
data_4 <- cSplit(data_4, "skill","/")
data_4 <- gather(data_4, "skill_num","skill",c(3:8))
data_4 <- data_4[c(1,2,4)]
data_4 <- data_4[!(is.na(data_4$skill) | data_4$skill==""), ]
#third time through
data_4 <- cSplit(data_4, "skill",";")
data_4 <- gather(data_4, "skill_num","skill",c(3:13))
data_4 <- data_4[c(1,2,4)]
data_4 <- data_4[!(is.na(data_4$skill) | data_4$skill==""), ]
#fourth time through
data_4 <- cSplit(data_4, "skill",":")
data_4 <- gather(data_4, "skill_num","skill",c(3:4))
data_4 <- data_4[c(1,2,4)]
data_4 <- data_4[!(is.na(data_4$skill) | data_4$skill==""), ]

#split the strings using "and" in the separate function
data_4 <- data_4 %>% separate(skill, c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21"), sep = "[:space:]and[:space:]")
data_4 <- gather(data_4, "skill_num","skill",c(3:23))
data_4 <- data_4[c(1,2,4)]
data_4 <- data_4[!(is.na(data_4$skill) | data_4$skill==""), ]

#split the strings using "OR" in the separate function
data_4 <- data_4 %>% separate(skill, c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21"), sep = "[:space:]or[:space:]")
data_4 <- gather(data_4, "skill_num","skill",c(3:23))
data_4 <- data_4[c(1,2,4)]
data_4 <- data_4[!(is.na(data_4$skill) | data_4$skill==""), ]

#split the strings using "OR" in the separate function
data_4 <- data_4 %>% separate(skill, c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21"), sep = "[:space:]with[:space:]")
data_4 <- gather(data_4, "skill_num","skill",c(3:23))
data_4 <- data_4[c(1,2,4)]
data_4 <- data_4[!(is.na(data_4$skill) | data_4$skill==""), ]



##indicate whether or not the skill is a programming language
#data_4$language <- ifelse(str_detect(data_4$skill,paste(languages_list, collapse = "|")), 1, 0)

#add up the rows that match
data_5 <- aggregate(count~skill, data=data_4, FUN=sum)
data_5 <-data_5[c(2,1)]

#remove any remaining punctation
data_5$skill <- gsub('[[:punct:] ]+',' ',data_5$skill)
data_5$skill <- str_trim(data_5$skill, side = c("both", "left", "right"))

#aggregate again after removing punctation
data_5 <- aggregate(count~skill, data=data_5, FUN=sum)
data_5 <-data_5[c(2,1)]

#captilize the words
data_5$skill <- capitalize(data_5$skill)
write.csv(data_5, file = "data_science.csv")

#Build a Word Cloud
# Install
install.packages("tm")  # for text mining
install.packages("SnowballC") # for text stemming
install.packages("wordcloud") # word-cloud generator 
install.packages("RColorBrewer") # color palettes
# Load
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")


set.seed(1234)
wordcloud(words = data_5$skill, freq = data_5$count, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))


#Build some graphs

data_6 <- filter(data_5, data_5$count > 15)
data_6 <- arrange(data_6, desc(data_6$count))

ggplot(data=data_6, aes(x=skill, y=data_6$count, fill = data_6$skill)) +
  geom_bar(stat="identity")+
  scale_colour_gradient2()+
  coord_flip()+
  scale_x_discrete(limits = data_6$skill)+
  theme_classic()+
  ggtitle("Data Science Skills")+
  xlab("Skill")+
  ylab("Count")

#Bar Graph with Gradient Applied
ggplot(data=data_6,aes(reorder(data_6$skill, data_6$count), data_6$count)) + 
  geom_col(aes(fill = data_6$count)) + 
  scale_fill_gradient2(low = "white", 
                       high = "blue", 
                       midpoint = median(data_6$count)) + 
  coord_flip() + 
  labs(x = "Skill", y = "Count", title = "Data Science Skills", subtitle = "Mined from Job Listings")


