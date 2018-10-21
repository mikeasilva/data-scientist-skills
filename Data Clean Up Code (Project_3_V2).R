library(data.table)
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


