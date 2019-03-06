# GettingAndCleaningDataAssignment

Getting and Cleaning Data Assignment

Please find enclosed an R script run_analysis.R The script:

Loads data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Makes a list of features from the features input file that match standard deviation and mean

Reads in only those columns matching the list from step 2

Combines the training input files into 1 table

Combines the test input files into 1 table

Merges the test and the training tables into one large table

Uses the descriptive activity names to name the activities in the table

Labels the table with descriptive variable names

Create a new tidy data set with just the average of the variables by subject and by activity.

This output data set is called tidydata.txt
