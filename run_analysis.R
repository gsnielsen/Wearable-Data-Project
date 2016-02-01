#1 Merges the training and the test sets to create one data set.

if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

unzip(zipfile="./data/Dataset.zip",exdir="./data")

dir_path <- file.path("./data" , "Wearable Dataset")
files<-list.files(dir_path, recursive=TRUE)

TestActivity  <- read.table(file.path(dir_path, "test" , "Y_test.txt" ),header = FALSE)
TrainActivity <- read.table(file.path(dir_path, "train", "Y_train.txt"),header = FALSE)

TestSubject  <- read.table(file.path(dir_path, "test" , "subject_test.txt"),header = FALSE)
TrainSubject <- read.table(file.path(dir_path, "train", "subject_train.txt"),header = FALSE)

TestFeatures  <- read.table(file.path(dir_path, "test" , "X_test.txt" ),header = FALSE)
TrainFeatures <- read.table(file.path(dir_path, "train", "X_train.txt"),header = FALSE)


##Merge

Subject <- rbind(TrainSubject, TestSubject)
Activity<- rbind(TrainActivity, TestActivity)
Features<- rbind(TrainFeatures, TestFeatures)

#set variable names

names(Subject)<-c("subject")
names(Activity)<- c("activity")
FeaturesNames <- read.table(file.path(dir_path, "features.txt"),head=FALSE)
names(Features)<- FeaturesNames$V2

#Final Merge

SubjectActivity <- cbind(Subject, Activity)
Data <- cbind(Features, SubjectActivity)


#2 Extracts only the measurements on the mean and standard deviation for each measurement

subsetFeaturesNames<-FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]

subsetNames<-c(as.character(subsetFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=subsetNames)


#3 Uses descriptive activity names to name the activities in the data set

LabelsActivity <- read.table(file.path(dir_path, "activity_labels.txt"),header = FALSE)

Data$activity<-factor(Data$activity);
Data$activity<- factor(Data$activity,labels=as.character(LabelsActivity$V2))


#4 Appropriately labels the data set with descriptive variable names

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))


## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr);
AvgData<-aggregate(. ~subject + activity, Data, mean)
AvgData<-AvgData[order(AvgData$subject,AvgData$activity),]
write.table(AvgData, file = "tidydata.txt",row.name=FALSE)
