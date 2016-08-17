# Flashcards for the Data Science specialization on Coursera

##What this repository offers:

* **Flashcards** for courses of the Data Science specialization on Coursera in CSV and (reformatted) RDA files

* A **script to convert CSV files exported from Studyblue into clean RDA files**, which can be loaded into R. (studyblue_csv_to_rda.R)

* A **script to review these flashcards** saved in RDA format (studyblue_rda_viewer.R)

##Available soon:

* An extension of the converter script, to convert it into clean CSV files and other useful formats.

##What is the point of converting Studyblue's csv files?

When you export your flashcards from Studyblue, the questions and answers are scattered all over the csv file. Plainly speaking, if you open the CSV file in Excel there is not one cell for the question and one cell for the answer. Neither can the CSV file be read into the R environment by using the read.csv command, no matter which separator is used. The converter script allows to detect the correct structure and convert the corrupt CSV files into a clean data.frame, saved as a RDA file.

In case you wonder about the use of exporting flashcards from Studyblue, bear in mind that these flashcards are user generated. Whereas our good old paper flashcards are rotting in our attics under a ever-increasing dust layer, they can still be used. But what are you going to do when Studyblue disappears or stops being free?