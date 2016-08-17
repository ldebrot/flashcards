##############################################################################
###                          STUDYBLUE CSV TO RDA CONVERTER                ###
##############################################################################
###
### 
### README : This is a small script to convert CSV files exported by Studyblue into clean Rda files.
### Please note that it takes into account the particular pattern of such files.
### Read.csv does not work for these files as line breaks in the flashcard text is wrongfully interpreted as a separation between cards.
### Therefore, the readlines function and a number of string manipulations are required.
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

# File choice
cat("\n *** \n \n Available CSV files in your working directory : \n")
print(dir(pattern=".csv")) # Show csv files in working directory
cat("\n Which file do you want to read? \n")
x <- (readline()) # Ask for input

# Check user input
if(is.na(as.numeric(x))) stop(errmsg1) 
x<-as.numeric(x)
if(x>length(dir(pattern=".csv")) || x<1) stop(errmsg1)
    
# If input correct (=corresponding to an actual file)
fnumber <- x
fcname <- dir()[fnumber]
flines <- readLines(con=fcname)

# Define starting and ending patterns
fpat_start <- '^"' # starts with a quotation mark
fpat_end <- '"$' # ends with a quotation mark

# Identify starting and ending elements in the read elements
startelements <- grep(pattern=fpat_start,x=flines)
endelements <- grep(pattern=fpat_end,x=flines)
if (length(startelements)!=length(endelements)) stop(errmsg2) # Just checking whether we identified an equal number of starting and ending elements

elementslength <- length(startelements)

elements <- list()
fcards <- data.frame()

for(i in 1:elementslength) {
    f_question <- NULL
    f_answer <- NULL
    
    elements[[i]] <- seq(from=startelements[i],to=endelements[i],by=1) # make a sequence from the starting to the ending element
    f_question <- str_split(string=flines[startelements[i]],pattern='","')[[1]][1] #take first part before the pattern (",") in the starting element 
    f_answer <- str_split(string=flines[startelements[i]],pattern='","')[[1]][2] #take second part after the pattern (",") in the starting element. This is usually the first part of the answer.
    if(length(elements[[i]])>1) {
        for (ii in 2:length(elements[[i]])) f_answer <- rbind(f_answer,flines[elements[[i]][ii]]) #add the other elements, which should contain only answer content
    }
    
    f_question <- cbind(f_question,"question",i) # make a row of the question, mark it as a question and assign it a number
    f_answer <- cbind(f_answer,"answer",i) # make a data frame of the answer element(s), mark it as answer content and assign it the same number
    f_colnames <- c("content","type","number") # name the columns appropriately
    colnames(f_question) <- (f_colnames)
    colnames(f_answer) <- (f_colnames)    
    fcards <- rbind(fcards,f_question,f_answer) # produce a clean data frame containing all content
}

## Set classes right
fcards$type <- as.character(fcards$type)
fcards$content <- as.character(fcards$content)
fcards$number <- as.numeric(as.character(fcards$number))

## Save it as a RDA file
fcrdaname <- sub(pattern=".csv",replacement=".Rda",x=fcname)
save(fcards,file=fcrdaname)
cat("\n \n *** \n Saved a RDA file containing the flashcard content in your working directory \n \n ")