

##Merges the training and the test sets to create one data set.
#opening some useful libs
library(data.table)
library(dplyr)

myZipFile <- paste(getwd(), "myZip.zip", sep = "/")

# read test: labels and data.
labels <- read.table( unz(myZipFile, "UCI HAR Dataset/test/y_test.txt") )
data <- read.table( unz(myZipFile,   "UCI HAR Dataset/test/X_test.txt" ) )
testset <- cbind( labels, data )

# read training: labels and data 
labels <- read.table( unz(myZipFile, "UCI HAR Dataset/train/y_train.txt") )
data <- read.table( unz(myZipFile, "UCI HAR Dataset/train/X_train.txt") )
trainingset <- cbind( labels, data )

# merge both data sets into the data frame df
data <- rbind( testset, trainingset )
df<-data.frame( data )

# some housekeeping
rm(data, labels, testset, trainingset)


##Extracts only the measurements on the mean and standard deviation for each measurement. 
# read the column names
cn <- read.table( unz(myZipFile,"UCI HAR Dataset/features.txt"), stringsAsFactors = FALSE )
cn <- cn[,2]
colnames( df ) <- c("label", cn)

# select columns with means
mean <- grep("mean", names(df), value = TRUE) 
toDrop <- grep("meanFre", names(df), value = TRUE)
dif<-setdiff(mean, toDrop)

# select columns with standard deviation
std <- grep("std()", names(df), value = TRUE)

# put the columns with means or standard deviation a the file df
df<-df[, c("label", dif, std)]

# some housekeeping
rm(dif, mean, std, toDrop)


##Uses descriptive activity names to name the activities in the data set
# create a vector holding the activities labels
ac <- c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", 
        "SITTING", "STANDING", "LAYING")

# add a new column 'activity' with poper labels
df<-mutate(df, activity = ac[df$label] )        
# drop the column label
df<-df[, names(df)[-1] ]                       


##give appropriately labels the data set with descriptive variable names. 
# some cleaning of the column names
cn<-names( df )                                 #extract the column names
cn <- gsub("\\(", "", cn)                       #remove the ('s 
cn <- gsub("\\)", "", cn)                       #remove the )'s 
cn <- gsub("-", "_", cn)                        #replace - by _
cn <- tolower(cn)                               #all column names in lowercase

# a columns name starts with either t (from time domain) or f (from 
# frequency domain), by use of FFT.
# to discriminate between those two kind domeins two lables are 
# introduce (time and FFT)
cn <- gsub("^t", "time_", cn)                   #replace first character by time_
cn <- gsub("^f", "fft_", cn)                    #replace first character by fft_
cn <- gsub("bodybody", "body", cn)              #remove some redundancy

# there are 3 mean subjects: body acceleration, gravity acceleration and body gyroscoop 
#(place in the x,y,z space).
#They have derivative forms: Jerk (the derivative of acceleration, or how fast 
# acceleration changes), Mag (the magnitude that combine all three axes), and JerkMag
# that Jerk and Mag combines
cn <- gsub("bodyacc", "body_acceleration_", cn)
cn <- gsub("gravityacc", "gravity_acceleration_", cn)
cn <- gsub("bodygyro", "body_gyroscoop_", cn)
cn <- gsub("__", "_", cn)

colnames( df ) <- cn                            #df gets its new column names
# at this point each column name consist of 3 parts: domein part, subject part,
# and measure part


##From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.
library( tidyr )

# the gather the culumns
df<-gather(df, subject, value, -activity)

#extract the domeins (time, fft) and put them in a new column domein
time <- df[ grepl("time_", df$subject), ]
time <- mutate(time, domein = "time", 
               subject = sub("time_", "", time$subject)
                )
fft <- df[ grepl("fft_", df$subject), ]
fft <- mutate(fft, domein = "fft", 
              subject = sub("fft_", "", fft$subject)
                )
df<-rbind(time, fft)    #put the results in the data frame df
rm(time, fft)           #some housekeeping

# extract the aspects of dimensions: x,y,z,  overall mean, overall std 
df <- mutate(df, dimension = "overall")         #create the column dimension 

# extract the sub sets
x <- df[ grepl("_x$", df$subject), ]
y <- df[ grepl("_y$", df$subject), ]
z <- df[ grepl("_z$", df$subject), ]
m <- df[ grepl("_mean$", df$subject), ]
s <- df[ grepl("_std$", df$subject), ]

# put the dimension in a new column
x <- mutate(x, dimension = "x", 
            subject = sub("_x", "", x$subject) )
y <- mutate(y, dimension = "y", 
            subject = sub("_y", "", y$subject) )
z <- mutate(z, dimension = "z", 
            subject = sub("_z", "", z$subject) )

# create df again
df <-rbind(x, y, z, s, m); 
rm(x, y, z, s, m)                               #some housekeeping

# extract the mean (the std is not required in the Assignment)
m <- df[ grepl("_mean$", df$subject), ]
df <- mutate(m, subject = sub("_mean$", "", m$subject))

# some housekeeping
rm( m)

# calculating the means
td<- setDT(df)[, lapply(.SD, mean), 
                 by=.(df$activity, df$subject, df$domein, df$dimension),
                 .SDcols=c("value")]

# put column names in place 
colnames( td ) <- c(names( df )[1:2], names( df )[4:5], "value")  

# one column is left to be tidy up, that is subject
td <- spread(td, subject, value)

# save the file td at disk
write.table(td, file = "tidy.txt", row.names = FALSE)     #write file to disk

