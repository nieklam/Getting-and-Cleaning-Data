How the script run_analysis.r works

There were several steps required to create a tidy data

1) 
The training set and the test set are read. 
In addition, for each set the column called “label”, represented by integer (1..6) is added. 
Next, both sets are stacked into single data file.

2) 
The the measurements on the mean and standard deviation for each measurement were extracted. 

To select the measurements on the mean it took three sub steps. 

At the first sub step, the descriptive variable names were added to the data set. 
At this stage, these variable names had a crude form, still useful to understand what kind of 
data each column holds. 

The second sub step was to collect the columns that contain the phrase “mean’. 
However, this gave the columns that contain the phrase “meanFre’ as well. 

In the third sub step those wrongly selected columns were dropped. 

Next, the measurements on the standard deviation for each measurement were extracted and added 
the measurements on the mean.

3) 
The next step was to use descriptive activity names to name the activities in the data set. 
A new column called “activity” was created. Then, it was filled with the proper label 
(("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING") 
by use the corresponding code found in column “label”. 

Than the column “label” was dropped.

4) 
The next step was to give appropriately labels the data set with descriptive variable names. 
Remember, as said in 2, each column had a crude description of its data.
 
To clean these descriptions the next sub step were done:
- remove the characters “(“’ and “)”               
- replace “-“ by “_”
- all column names were set in lowercase
- several parts were replace by better ones, for instance “bodyacc” by  “body_acceleration”

At this point each column name consist of 3 parts: 
- the domein part (either time or fft), 
- the subject part
- measure part. 
Each part will explained later.

5)
the tidy the data further serveral steps were used:
- the columns were gathered to 3 variables (=columns): "activity" "subject"  "value" 
- the domeins (time, fft) were extracted and put in a new column "domein"
- the aspects of dimensions ( x,y,z,  overall mean, overall std) were extracted and
  put in the new column "dimension"
- the mean values were extrected (the std was not required in the Assignment)
- the means were calculeted. The applied factors were: activity, subject, domein, dimension
- by use of spread each subject got its own column

6) 
Save the file td at disk


