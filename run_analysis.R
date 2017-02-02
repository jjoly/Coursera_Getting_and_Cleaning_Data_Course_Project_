# This script is for the final course project for the Coursera course "Getting and Cleaning Data"

# I'm assuming that the zip file is in the same folder as the script, if not, change the path below
unzip("getdata_projectfiles_UCI\ HAR\ Dataset.zip", overwrite = TRUE)

# Some path names that will be useful later
root_path <- "./UCI HAR Dataset/"  # This is the unzipped folder containing all the data files
train_path <- paste(root_path,"train", sep = "") # path to the "train" folder
test_path <- paste(root_path, "test", sep = "")  # path to the "test" folder

#################################################################

#First, get the list of all features
features_filename <- paste(root_path, "features.txt", sep = "")
features_df <- read.table(features_filename, stringsAsFactors = FALSE)
features_list <- features_df[,2]
rm(features_df)  # I will be removing the data frames after use to free memory

#################################################################

#Now get the lines with "mean" and "std" in the feature name
mean_lines <- grep("mean", features_list) # This list will give the column ids with "mean" in the name
std_lines <- grep("std", features_list) # Same but column names with "std"

#merge the two lists
variable_lines <- sort(append(mean_lines,std_lines)) 

# I will use the names from the names in " 
variable_labels <- features_list[variable_lines]

#################################################################

# Get the activity names from the file "activity_labels.txt"
activity_filename <- paste(root_path, "activity_labels.txt", sep = "")
activity_df <- read.table(activity_filename, stringsAsFactors = FALSE)

#################################################################

#Read in the "X_***.txt", "subject_***.txt" and "y_***.txt" files where *** is either "test" or "train"
tmp_subject_train_list <- read.table(paste(train_path, "subject_train.txt", sep = "/"))
tmp_train_df <- read.table(paste(train_path, "X_train.txt", sep = "/"))
tmp_train_labels_list <- read.table(paste(train_path, "y_train.txt", sep = "/"), stringsAsFactors = FALSE)

tmp_subject_test_list <- read.table(paste(test_path, "subject_test.txt", sep = "/"))
tmp_test_df <- read.table(paste(test_path, "X_test.txt", sep = "/"))
tmp_test_labels_list <- read.table(paste(test_path, "y_test.txt", sep = "/"), stringsAsFactors = FALSE)

# bind the data frames from the "test" set and the "train" set together
output_df <- rbind(tmp_train_df, tmp_test_df)

#Now keep only the relevant columns, using variable_lines
output_df <- output_df[, variable_lines]
#Give the columns their names
names(output_df) <- variable_labels

#Remove unused data frames, lists and lists
rm(tmp_train_df, tmp_test_df)

#################################################################

#Now add the activity list from the "train" and "test" data sets
#into a single column

tmp_activity_list <- rbind(tmp_train_labels_list, tmp_test_labels_list)

#And replace the activity number with its name
for (i_activity in seq_along(tmp_activity_list)){
  tmp_activity_list[i_activity] <- activity_df[tmp_activity_list[[i_activity]],2 ]
}

# Now append this column to the output_df on the left side
output_df <- cbind( tmp_activity_list, output_df)
# and name the column "Activity"
names(output_df)[1] <- "Activity"

#################################################################

#Add the subject ids column to the output_df 
output_df <- cbind(rbind(tmp_subject_train_list, tmp_subject_test_list), output_df)
#Name this column "Subject"
names(output_df)[1] <- "Subject"

#Delete temporary lists and data frames
rm(tmp_activity_list, tmp_subject_test_list, tmp_subject_train_list, tmp_test_labels_list, tmp_train_labels_list)
rm(activity_df)

#################################################################

#change Subject and Activity to factors (this will help getting the averages later)
output_df$Subject <- as.factor(output_df$Subject)
output_df$Activity <- as.factor(output_df$Activity)

#################################################################

## Now I need to get the average of each variable for each activity and each subject
## I will use the aggregate function over the two factor variables "Subject" and "Activity"
output_avg_df <- aggregate(output_df[, 3:ncol(output_df)], by=list(output_df$Subject, output_df$Activity), mean)

#Delete un-averaged output data frame
rm(output_df)

## Rename the first two columns as aggregate changed their names

names(output_avg_df)[1] <- "Subject"
names(output_avg_df)[2] <- "Activity"

## I now change the names of the columns to show these are the average for each activity and each subject

#Write the data frame to a file
write.table(output_avg_df, paste("tidy.txt", sep = "/"), sep = "\t", append = F, row.name=FALSE)



