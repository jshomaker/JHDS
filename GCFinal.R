## Coursera, Johns Hopkins Data Science
## Getting & Cleaning Data, Final Assignment
## Author:  John Shomaker
## Date: April, 2016

## Install packages for dplyr and reshape2

library(plyr)
library(dplyr)

## Read in all relevant .TXT tables into data.frames
## X_* [*_data]:            raw data (561 column metrics; 2947 rows for test, 7352 for train)
## Y_* [*_labels]:          1 column activity # (1-6) for each row (observation)
## subject_* [*_subjects]:  1 column subject # (1-30), designating participants (1-24 test, 25-30 train)
## features:                561 column labels (generic to both sets)
## activity_labels:         activity labels (lookup) for *_labels (generic to both sets)

setwd("/Users/john/JHDS/Get-Clean/UCIDataset/")
activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")

setwd("/Users/john/JHDS/Get-Clean/UCIDataset/test/")
test_data <- read.table("X_test.txt")
test_labels <- read.table("Y_test.txt")
test_subjects <- read.table("subject_test.txt")

setwd("/Users/john/JHDS/Get-Clean/UCIDataset/train/")
train_data <- read.table("X_train.txt")
train_labels <- read.table("Y_train.txt")
train_subjects <- read.table("subject_train.txt")

setwd("/Users/john/JHDS/Get-Clean/")

## Merge test & train data, and relabel columns with features
## Keep just those columns with mean() or std()

m_data <- rbind(test_data, train_data)
names(m_data) <- features[, 2]
m_data <- m_data[, grepl("mean|std", names(m_data))]
names(m_data) <- gsub("[-()]", "", names(m_data))

## Separately merge (rbind) labels (activity codes) and subjects for test & train datasets
## Relabel columns across datasets
## Merge activity codes/description tables (lookup)
## Merge subject, activity, raw data into comb_data

m_labels <- rbind(test_labels, train_labels)
m_subjects <- rbind(test_subjects, train_subjects)

colnames(m_subjects)[1] <- "subject"
colnames(m_labels)[1] <- "act_code"
colnames(activity_labels)[1] <- "act_code"
colnames(activity_labels)[2] <- "activity"

m_activity <- merge(m_labels, activity_labels, by = "act_code")
comb_data <- cbind(m_subjects, m_activity, m_data)
comb_data <- comb_data[, -c(2)]

## Turn key fields into factors (so 'means' only produced for numerics)
## group/combine the dataset by activity (primary) and subject (secondary)
## find the mean for each numeric column
## reorder by the keys
## and, write to an output file

comb_data$subject <- as.factor(comb_data$subject)
tiny_data <- aggregate(. ~subject + activity, comb_data, mean)
tiny_data <- tiny_data[order(tiny_data$subject,tiny_data$activity),]

print(head(tiny_data[, 1:5]), 10)
print(dim(tiny_data))

write.table(tiny_data, "tidy.txt", row.names = FALSE, quote = FALSE)
