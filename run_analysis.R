# GettingCleaningDataAssignment.R

# Here are the data for the project: 
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set. 
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set 
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the 
# average of each variable for each activity and each subject. 

# ------------------------------------------------------------
# More Info
# 30 volunteers, each performs six activities
# for each activity, have 2 variables (3-axial linear acceleration and 3-axial angular velocity)
# features are recorded 
# ----------------
# First download & unzip the data
setwd("C:/Users/tkohler/Desktop/coursera/CleaningData")
dataset <- "getdata_projectfiles_UCI HAR Dataset.zip"
if (!file.exists(dataset)) {
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, destfile = "C:/Users/tkohler/Desktop/coursera/CleaningData/gdp.csv")
}
folder <- "UCI HAR Dataset"
if (!exists(folder)) {
  # unzip the file to the folder
  unzip(dataset)
}

# Read tables 
getwd()

# activity labels are (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity")) 
activity_labels$activity <- tolower(activity_labels$activity)
head(activity_labels)
# features contains the 561 column headers for the test and train sets
# this is a complete list of variables of each feature vector
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("featurenumber","functions")) 
str(features)
# functions are listed as factors - make them character
features[,2] <- as.character(features[,2])


# ----- Make list of functions/features out of 'features' that match mean & std
# -------Needed for step 2
keepnums <- grep(".*mean.*|.*std.*", features[,2]) # get column nums where col2 matches grep
keepnames <- features[keepnums,2] # then get the actual names
# substitute out dashes & brackets
keepnames <- gsub('[-()]', '', keepnames)
keepnames = gsub('-mean', 'mean', keepnames)
keepnames = gsub('-std', 'std', keepnames)


# training data set - only read in mean & std columns
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
NROW(x_train) # 7352
x_train <- x_train[,keepnums]
colnames(x_train)

# subject number - 70% of volunteers/subjects 
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject") 
nrow(subject_train) #7352

# contains 7352 obs of 5,4,6,1,3,2 
# (activity numbers that match activities in activity_labels.txt)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activitynum")

# Combine the train info into 1 table
alltrain <- cbind(subject_train, y_train, x_train)
nrow(alltrain) # 7352
colnames(alltrain)
colnames(alltrain) <- c("subject","activitynum",keepnames)

# ---------------------------
# subject number - 30% of volunteers/subjects 
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject") 
nrow(subject_test) #2947

# test set 
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions) 
x_test <- x_test[,keepnums]
colnames(x_test)
nrow(x_test) #2947

# get labels
# contains 2947 obs of 5,4,6,1,3,2 
# (activity numbers that match activities in activity_labels.txt)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activitynum") 

# Combine the test info into 1 table
alltest <- cbind(subject_test,y_test,x_test)
nrow(alltest) # 2947
colnames(alltest)
colnames(alltest) <- c("subject","activitynum",keepnames)


# Part 1. Merge training & test data sets
# want rbind
alldata <- rbind(alltest,alltrain)
nrow(alldata)
colnames(alldata)
NROW(alldata) # 10299

# ------Part 2: Extract mean & std
# already done in Part 1

# Part 3. Uses descriptive activity names to name the activities in the data set
# Join the real activity label to the activity code
library(reshape2)
colnames(alldata)
str(alldata)
# create proper labels for activities
alldata$activitylabels <- factor(alldata$activitynum, levels=activity_labels$code, labels = activity_labels$activity)
head(alldata)
#alldata$activitynum <- alldata$activitylabels
#alldata <- alldata[,-82] # dropping old activitylabels


# Part 4. Appropriately labels the data set with descriptive variable names.
# use gsub
names(alldata)<-gsub("Acc", "Accelerometer", names(alldata))
names(alldata)<-gsub("Gyro", "Gyroscope", names(alldata))
names(alldata)<-gsub("BodyBody", "Body", names(alldata))
names(alldata)<-gsub("std", "Std", names(alldata))
names(alldata)<-gsub("mean", "Mean", names(alldata))
names(alldata)<-gsub("^f", "Frequency", names(alldata))
names(alldata)<-gsub("^t", "Time", names(alldata))
names(alldata)<-gsub("Mag", "Magnitude", names(alldata))
write.table(alldata, "nottidy.txt", sep=',', quote = FALSE)

# Part 5. From the data set in step 4, creates a second, independent tidy data set with the 
# average of each variable for each activity and each subject.
# find mean for each activity and for each subject
alldata$subject <- as.factor(alldata$subject)
out1 <- melt(alldata, id=c("subject", "activitylabels")) #,measure.vars="FrequencyBodyGyroscopeMeanX")
head(out1,100)
tail(out1,100)

tidydata <- dcast(out1, subject + activitylabels ~ variable, mean)
head(tidydata)
tail(tidydata)
nrow(tidydata) # 180 rows

write.table(tidydata, "tidydata.txt", sep=',', quote = FALSE)

