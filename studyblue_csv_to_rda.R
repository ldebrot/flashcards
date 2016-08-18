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
errmsg2 <- "ERROR 2 - Something went wrong with the identification of the starting and ending elements, despite 100 sincere attempts. Sorry, I failed you... :("

# File choice
cat("\n *** \n \n Available CSV files in your working directory : \n")
filepattern <- "\\.csv$" # Define file extension pattern
print(dir(pattern=filepattern)) # Show csv files in working directory
cat("\n Which file do you want to read? \n")
x <- (readline()) # Ask for input

# Check user input
if(is.na(as.numeric(x))) stop(errmsg1) 
x<-as.numeric(x)
if(x>length(dir(pattern=filepattern)) || x<1) stop(errmsg1)
    
# If input correct (=corresponding to an actual file)
fnumber <- x
fcname <- dir(pattern=filepattern)[fnumber]
flines <- readLines(con=fcname)

# Check whether first line starts with a quotation mark (as Studyblue provides two types of csv files...)
tmp_1stchar <- substr(flines[1],1,1)

# Apply restrictive patterns
fpat_start <- '[,]{1}["]{1}' # starts with a quotation mark (old pattern : '^"')
fpat_end <- '[^"]["]{1}$' # ends with a quotation mark

    fpat_start <- '^"' # starts with a quotation mark
    fpat_end <- '"$' # ends with a quotation mark

# Identify starting and ending elements in the read elements
startelements <- grep(pattern=fpat_start,x=flines)
endelements <- grep(pattern=fpat_end,x=flines)


# Check whether equal numbers of start- and endelements
safetycount <- 0
checkreport <- "" #REPORT
while (length(startelements)!=length(endelements)) {
    safetycount <- safetycount + 1
    if (safetycount>100) stop(errmsg2)
    tmp_counts <- max(c(length(startelements),length(endelements)))
    for (i in 1:tmp_counts) {
        if(endelements[i]<startelements[i]) { #If endelement is below or equal to the next starting element, there is a missing endelement
            newreport <- paste("\n \n Unequal number of start- and endelements at element #",i," which is startelement #",startelements[i]," and endelement #",endelements[i]," \n \n ",collapse="")
            checkreport <- c(checkreport,newreport)

            # Check whether the previous endelement was right
            tmp_pos <- endelements[i-1] #Get the position of the last endelement
            tmp_nxt <- flines[tmp_pos+1] #Get the element after the position of the last endelement

            # Check whether this looks like a start element
            tmp_eval <- 0
            if(length(grep(pattern='[,]{1}["]{1}',x=tmp_nxt))==1) tmp_eval <- tmp_eval + 1
            if(length(grep(pattern='^"[A-Z]',x=tmp_nxt))==1) tmp_eval <- tmp_eval + 1

            if(tmp_eval!=2) { #the next element is NOT a starting element, so the endelement is wrong !
                newreport <- paste("Endelement wrong, next element is NOT a starting element. Endelement deleted.")
                checkreport <- c(checkreport,newreport)
                oldendelements <- endelements
                endelements <- NULL
                endelements[1:(i-2)] <- oldendelements [1:(i-2)]
                endelements[(i-1):(length(oldendelements)-1)] <- oldendelements[i:length(oldendelements)]
            } 

            if(tmp_eval==2) { #the next element IS INDEED a starting element, so the startelement is wrong
                newreport <- paste("Startelement wrong, element following last endelement IS a starting element. Startelement added.")
                checkreport <- c(checkreport,newreport)
                oldstartelements <- startelements
                startelements <- NULL
                startelements[1:(i-1)] <- oldstartelements [1:(i-1)]
                startelements[i] <- tmp_pos+1
                startelements[(i+1):(length(oldstartelements)+1)] <- oldstartelements[i:length(oldstartelements)]
            }
            
            break
        }
    }
}

#REPORT
newreport <- "\n \n Conversion all fine."
checkreport <- c(checkreport,newreport)


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
cat(checkreport)
cat("\n \n *** \n Saved a RDA file containing the flashcard content in your working directory \n \n ")