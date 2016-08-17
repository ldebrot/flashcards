##############################################################################
###                          STUDYBLUE RDA VIEWER                          ###
##############################################################################
###
### 
### README : This is a small script to view RDA files, converted from CSV files exported by Studyblue by the studyblue_csv_to_rda.R script.
###
### REQUIREMENTS : This script installs and uses the stringr package
###
### LEGAL : For the legal people out there, this script is not linked in any way to Studyblue. It just happens that I wrote it to handle files exported from this platform.

# Install stringr package if necessary, then load it
list.of.packages <- c("stringr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])] # check which packages are installed
if(length(new.packages)) install.packages(new.packages) # if not install, install
for (i in 1:length(list.of.packages)) library(list.of.packages[i],character.only = TRUE) # load them

# Send working directory to the one in which flashcardreader is located
setwd(dirname(sys.frame(1)$ofile))
cat("\n Working directory set to the one in which this script is located \n")

# Set error messages for further use
errmsg1 <- "ERROR 1 - This is not a correct choice - choose a number corresponding to a file"
errmsg2 <- "ERROR 2 - Something went wrong with the identification of the starting and ending elements. Their number is not equal. Sorry, I failed you... :("
errmsg3 <- "ERROR 3"
errmsg4 <- "ERROR 4"


# File choice
cat("\n *** \n \n Available RDA files in your working directory : \n")
filepattern <- "\\.Rda$" # Define file extension pattern
print(dir(pattern=filepattern)) # Show csv files in working directory
cat("\n Which file do you want to view? \n")
x <- (readline()) # Ask for input

# Check user input
if(is.na(as.numeric(x))) stop(errmsg1) 
x<-as.numeric(x)
if(x>length(dir(pattern=filepattern)) || x<1) stop(errmsg1)
    
# If input correct (=corresponding to an actual file), load file
fnumber <- x
fcname <- dir(pattern=filepattern)[fnumber]
load(fcname)
fcards$type <- as.character(fcards$type)
fcards$content <- as.character(fcards$content)
fcards$number <- as.numeric(as.character(fcards$number))

# Identify parameters
fcards_nb <- length(unique(fcards$number))
temp_msg <- paste(c("\n Flashcard file correctly loaded. \n It contains ",fcards_nb," questions. \n"),collapse="")
cat(temp_msg)

# Ask user if (s)he still wants to review the flashcards
cat('\n Type "y" if you want to review the flashcards in random order or anything else to quit \n')
x <- (readline()) # Ask for input

# check answer
if (str_to_lower(x)!="y") stop("Okay, by then.")

# Reorder questions
f_order <- seq(from=1, to=fcards_nb, by=1)
set.seed(as.numeric(Sys.time()))
f_order <- sample(f_order)

# Set repetitive messages
repmsg1 <- '\n \n \n Type any button to reveal the answer (except for "q/Q" or "exit" to leave)'
repmsg2 <- '\n \n \n Type: \n --> "c" if you had the right answer \n --> "s" if you want to take the question out of the deck \n --> "f" if you did not have the right answer \n --> "q" to quit' 

# Reset stats
f_successes <- 0
f_attempts <- 0
f_skipped <- 0

# Define byebye function
byebye <- function() {
    tmpmsg <- paste("\n Leaving flashcard reviewer. Just a few stats: \n \t Number of successes : ",f_successes," \n \t Number of skipped questions : ",f_skipped," \n \t Number of attempts : ",f_attempts," \n \n ***", collapse = "")
    cat(tmpmsg)
    stop("just kidding, no error there, just leaving the script...")
}

while (length(f_order)>0) {
    f_current <- f_order[1] # define current flashcard
    f_order <- subset(f_order,f_order!=f_current) # take it out of the deck
    f_current_question <- subset(x=fcards,number==f_current & type=="question")$content
    tmpmsg <- paste(c('\n *** \n \n Question #',f_current," : \n",f_current_question,"\n \n",repmsg1),collapse="")
    cat(tmpmsg)

    x <- (readline()) # Ask for input

    # Check if exit
    x <- str_to_lower(x)
    if(x=="q"||x=="exit") byebye()
    
    # Show answer
    f_current_answer_temp <- subset(x=fcards,number==f_current & type=="answer")$content
    f_current_answer <- "\n Answer: \n"
    for (i in 1:length(f_current_answer_temp)) f_current_answer <- paste(f_current_answer," \n ",f_current_answer_temp[i])
    cat(f_current_answer)

    # Ask for evaluation
    cat(repmsg2)
    x <- (readline()) # Ask for input
    x <- str_to_lower(x)

    f_attempts <- f_attempts +1 #increase attempt count

    # If input = c
    if(x=="c") f_successes <- f_successes +1 # increase success count

    # If input = n
    if(x=="n") f_order <- c(f_order,f_current) # put the question back in the deck
    
    # If input = s
    if(x=="s") f_skipped <- f_skipped +1 # increase skip count
    
    # If exit
    if(x=="q"||x=="exit") byebye()
}