library(tidyverse)
library(knitr)

# this just gets a list of all the files in the downloaded data directors
files_path <- file.path("/Users/brodyvogel/Desktop/Coursera Data" , "UCI HAR Dataset")
files <- list.files(files_path, recursive=TRUE)

# pulls the files into specific tables
# files for the activity data
Activity_Test  <- read.table(file.path(files_path, "test" , "Y_test.txt" ), header = FALSE)
Activity_Train <- read.table(file.path(files_path, "train", "Y_train.txt"), header = FALSE)
# and the subject files
Subject_Test  <- read.table(file.path(files_path, "test" , "subject_test.txt"), header = FALSE)
Subject_Train <- read.table(file.path(files_path, "train", "subject_train.txt"), header = FALSE)
# and the features files
Features_Test  <- read.table(file.path(files_path, "test" , "X_test.txt" ), header = FALSE)
Features_Train <- read.table(file.path(files_path, "train", "X_train.txt"), header = FALSE)

# now we'll merge everything
# activity
Activity<- rbind(Activity_Train, Activity_Test)
# subject
Subject <- rbind(Subject_Train, Subject_Test)
# features
Features<- rbind(Features_Train, Features_Test)
# give everything good names
# activity
names(Activity)<- c("Activity")
# subject
names(Subject)<-c("Subject")
# get the names for the features
Features_Names <- read.table(file.path(files_path, "features.txt"), head=FALSE)
# and assign them
names(Features)<- Features_Names$V2
# finally, actually merge everything to 
Data <- do.call('cbind', list(Activity, Subject, Features))

# get only the mean and standard deviation stats
mean_or_sd <- Features_Names$V2[grep("mean\\(\\)|std\\(\\)", Features_Names$V2)]
mean_or_sd_names <- c(as.character(mean_or_sd), "Subject", "Activity" )
# do the actual subsetting
Data <- Data[, names(Data) %in% mean_or_sd_names]

# give the proper names to the activity
Proper_Labels <- read.table(file.path(files_path, "activity_labels.txt"), header = FALSE)
Data$Activity <- Proper_Labels$V2[Data$Activity]
# and descriptive names
names(Data) <- gsub("^t", "Time", names(Data))
names(Data) <- gsub("^f", "Frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))

# create the second, tidy data set with the averages
tidy_data <- aggregate(. ~Subject + Activity, Data, mean)
tidy_data <- tidy_data[order(tidy_data$Subject, tidy_data$Activity), ]
# save it
write.table(tidy_data, file = "/Users/brodyvogel/Desktop/tidy_data.txt", row.name=FALSE)

# codebook
knit2html("codebook.Rmd")
