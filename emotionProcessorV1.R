###############################################################
#emotionProcessorV1
# created on 2019/08/20 by ASC
# last updated on 2019/08/24 by ASC
#
#UNDER CONSTRUCTION: Add code to exclude those who fail attention check
###############################################################
rm(list = ls())
library(readxl)
library(readr)
library(dplyr)
library(purrr)
filepath <- '/media/adam/AdamSSD2/My Documents/Academic/1-research/1-projects/29-pride_and_shame_replications/extension_studies/R_analyses/'
filePride <- paste0(filepath,'Pride - multi output.xlsx')
fileShame <- paste0(filepath,'Shame - multi output.xlsx')

pride <- read_excel(filePride, skip = 1)
shame <- read_excel(fileShame, skip = 1)

colnames(pride) <- substring(colnames(pride),1,80)
colnames(shame) <- substring(colnames(shame),1,80)

pride <- rename(pride, sex = 19)
shame <- rename(shame, sex = 19)
#-----------------------------------------------------
#ConditionConstructor - run on each condition  to extract observations(rows) and measurements (cols) specific to each condition
#-----------------------------------------------------
conditionConstructor <- function(df,cols,mcols,fcols,lastCol,lastDataCol){
  #-----------------------------------------------------
  #Select columns in cond, filter empty rows
  #-----------------------------------------------------
  cond <- df[,cols] %>%
    filter(!is.na(.[lastCol]))
    #-----------------------------------------------------
  #Extract male and female data into dfs, select non-empty columns
  #-----------------------------------------------------
  mVal <- cond %>%
    filter(sex == 1) %>%
    select(mcols)
  fVal <- cond %>%
    filter(sex == 2) %>%
    select(fcols)
  #-----------------------------------------------------
  #match column names and rbind
  #-----------------------------------------------------
  colnames(fVal) <- colnames(mVal)
  cond1 <- rbind(mVal,fVal)
  #-----------------------------------------------------
  #get item means
  #-----------------------------------------------------
  meanCond1 <- cond1 %>%
    summarize_at(c(2:lastDataCol),mean)
}

#-----------------------------------------------------
#Setup cols for each condition, then for each sex once condition cols have been selected
#-----------------------------------------------------
valCols <- c(19,28:77,426:428,431)
prideCols <- c(19,86:135,426:428,432)
commCols <- c(19,144:193,426:428,433)
treatCols <- c(19,202:251,426:428,434)
investCols <- c(19,260:309,426:428,435)
pursueCols <- c(19,318:367,426:428,436)
revCols <- c(19,376:425,426:428,437)

mcols <- c(1,2:26,52:55)
fcols <- c(1,27:51,52:55)
lastPrideCol <- 55
lastPrideDataCol <- 26
  
#-----------------------------------------------------
#run conditionConstructor on each pride condition
#-----------------------------------------------------
valCond <- conditionConstructor(pride,valCols,mcols,fcols,lastPrideCol,lastPrideDataCol)
prideCond <- conditionConstructor(pride,prideCols,mcols,fcols,lastPrideCol,lastPrideDataCol)
commCond <- conditionConstructor(pride,commCols,mcols,fcols,lastPrideCol,lastPrideDataCol)
treatCond <- conditionConstructor(pride,treatCols,mcols,fcols,lastPrideCol,lastPrideDataCol)
investCond <- conditionConstructor(pride,investCols,mcols,fcols,lastPrideCol,lastPrideDataCol)
pursueCond <- conditionConstructor(pride,pursueCols,mcols,fcols,lastPrideCol,lastPrideDataCol)
revCond <- conditionConstructor(pride,revCols,mcols,fcols,lastPrideCol,lastPrideDataCol)

#-----------------------------------------------------
#create table, write to disk
#-----------------------------------------------------
prideCondMeans <- data.frame(as.numeric(valCond),as.numeric(prideCond),as.numeric(commCond),as.numeric(treatCond),
                             as.numeric(investCond),as.numeric(pursueCond),as.numeric(revCond))

write_csv(prideCondMeans,paste0(filepath,'prideCondMeans.csv'))

#-----------------------------------------------------
#Setup cols for each condition, then for each sex once condition cols have been selected
#-----------------------------------------------------
devalCols <- c(19,29:82,455:457,460)
shameCols <- c(19,91:144,455:457,461)
hideCols <- c(19,153:206,455:457,462)
lieCols <- c(19,215:268,455:457,463)
destroyCols <- c(19,277:330,455:457,464)
threatenCols <- c(19,339:392,455:457,465)
revCommCols <- c(19,401:454,455:457,466)

mShamecols <- c(1,2:28,56:59)
fShamecols <- c(1,29:55,56:59)
lastShameCol <- 59
lastShameDataCol <- 28

#-----------------------------------------------------
#run conditionConstructor on each shame condition
#-----------------------------------------------------
devalCond <- conditionConstructor(shame,devalCols,mShamecols,fShamecols,lastShameCol,lastShameDataCol)
shameCond <- conditionConstructor(shame,shameCols,mShamecols,fShamecols,lastShameCol,lastShameDataCol)
hideCond <- conditionConstructor(shame,hideCols,mShamecols,fShamecols,lastShameCol,lastShameDataCol)
lieCond <- conditionConstructor(shame,lieCols,mShamecols,fShamecols,lastShameCol,lastShameDataCol)
destroyCond <- conditionConstructor(shame,destroyCols,mShamecols,fShamecols,lastShameCol,lastShameDataCol)
threatenCond <- conditionConstructor(shame,threatenCols,mShamecols,fShamecols,lastShameCol,lastShameDataCol)
revCommCond <- conditionConstructor(shame,revCommCols,mShamecols,fShamecols,lastShameCol,lastShameDataCol)

#-----------------------------------------------------
#create table, write to disk
#-----------------------------------------------------
shameCondMeans <- data.frame(as.numeric(devalCond),as.numeric(shameCond),as.numeric(hideCond),as.numeric(lieCond),
                             as.numeric(destroyCond),as.numeric(threatenCond),as.numeric(revCommCond))

write_csv(shameCondMeans,paste0(filepath,'shameCondMeans.csv'))