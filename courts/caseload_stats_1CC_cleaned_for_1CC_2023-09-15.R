#---------------------------------------------------------------------------------#
#NOTES:
#1. confirm that of the 3 files on the JIRA ticket, they are using JPS-38854-AR
# master_1cc and JPS-38854 are very different but master_1cc and JPS-38854-AR after filtering for court == IC and case type = PC are the same
# ICC master is all 1C, PC; JPS-38854 and JPS-38854-AR are a mix

# 2. master_1cc:
#pas (3031) is a match between 1cc xlsx and R
#filings (1746) is a match between 1cc xlsx and R
#terminated (2810) is a match between 1cc xlsx and R if filtering by Disp Date only
#terminated (1716) is a match between 1cc xlsx and R if filtering by Disp Date and disp code not NA
#pae is NOT a match between 1cc xlsx (2949) and R (1967); also PAE does not equal caseload

# 3. RSO #s in table on second sheet
# -> was able to calculate her #s for filed and terminated but not PAS

# 4. send Sharon list of cases on my list but not CapG

# 5. CapG extract is created based on case status date, not disp date, matters for PAS which also affects terminated/PAE

# 6. something wrong with DISP DATES, cases with DISP DATE not empty but DISP CODE is empty, case look up confirms these aren't the actual DISP DATES
#---------------------------------------------------------------------------------#
#clear workspace and load libraries----
#---------------------------------------------------------------------------------#
rm(list = ls())

library(readxl)
library(dplyr)

#---------------------------------------------------------------------------------#
#import data----
# master_1cc = sheet #3 in xlsx shared by Sharon; according to Sharon, this is the master extract from CapG
    # -> after inspecting master_1cc, it is not identical to master file from CapG; it has been filtered for PC and 1C
# jps_38854_AR = CapG extract downloaded from JPS-38854
#---------------------------------------------------------------------------------#

path_sharon_files <- "H:\\p19_annual_report_stat_supp\\1CC_caseload_and_time_to_termination\\from_sharon\\"
master_1cc <- read_excel(paste0(path_sharon_files, "FY22 1C PC Table 8 Extract fr CapG.xlsx"), sheet = 3)
# jps_38854 <- read_excel("JPS-38854\\JPS-38854 PC FC Extract for FY2022.xlsx")
# jps_38854_non_NEF <- read_excel("JPS-38854\\JPS-38854 PC FC Extract for FY2022 last non-NEF dkt.xlsx")
jps_38854_AR <- read_excel(paste0(path_sharon_files, "JPS-38854\\PC-FC Annual Stats Report FY22.xlsx"))

#---------------------------------------------------------------------------------#
#wrangle dates----
#---------------------------------------------------------------------------------#
#convert dates from character type to date type
master_1cc <- master_1cc %>% 
  mutate(INIT_DATE2 = as.Date(INIT_DATE, format = "%Y%m%d"),
         DISPOSITION_DATE2 = as.Date(DISPOSITION_DATE, format = "%Y%m%d"),
         CASE_STATUS_DATE2 = as.Date(CASE_STATUS_DATE, format = "%Y%m%d"))

#---------------------------------------------------------------------------------#
#QA: check if filtered AR list and master_1cc are a one-to-one match----
#change if(FALSE) to if(TRUE) to run
#---------------------------------------------------------------------------------#
if(FALSE){
  jps_38854_AR <- jps_38854_AR %>% 
    filter(COURT=="1C", CASE_TYPE == "PC") %>% 
    mutate(INIT_DATE2 = as.Date(INIT_DATE, format = "%Y%m%d"),
           DISPOSITION_DATE2 = as.Date(DISPOSITION_DATE, format = "%Y%m%d"),
           INIT_CASE_STATUS_DATE2 = as.Date(INIT_CASE_STATUS_DATE, format = "%Y%m%d"),
           CASE_STATUS_DATE2 = as.Date(CASE_STATUS_DATE, format = "%Y%m%d"))
  
  jps_38854_AR_abb <- jps_38854_AR %>% 
    select(CASE_ID) %>% 
    arrange(CASE_ID)
  
  master_1cc_abb <- master_1cc %>% 
    select(CASE_ID) %>% 
    arrange(CASE_ID)
  
  #CHECK #1:
  all.equal(master_1cc_abb, jps_38854_AR_abb)
  #IT'S A MATCH
  
  #CHECK #2: compare CapG on JIRA to 1CC master file -> MATCH!
  jps_anti_1cc <- jps_38854_AR %>% 
    anti_join(master_1cc, by = "CASE_ID")
  
  #CHECK #3: anti-join in other direction -> MATCH!
  cc1_anti_jps <- master_1cc %>% 
    anti_join(jps_38854_AR, by = "CASE_ID")
}

#---------------------------------------------------------------------------------#
#1CC CASELOAD STATS----
#using ICC criteria, see xlsx sheet #2
#---------------------------------------------------------------------------------#
pas_1cc <- master_1cc %>% 
  filter(INIT_DATE2 < "2021-07-01" & (is.na(DISPOSITION_DATE2) | DISPOSITION_DATE2 >= "2021-07-01"))
#3031 defts/rows/records

filed_1cc <- master_1cc %>% 
  filter("2021-07-01" <= INIT_DATE2, INIT_DATE2 <= "2022-06-30")
#1746 defts/rows/records

terminated_1cc <- master_1cc %>% 
  filter("2021-07-01" <= DISPOSITION_DATE2, DISPOSITION_DATE2 <= "2022-06-30")
#2810 defts/rows/records -> filter by disp date only

terminated2_1cc <- master_1cc %>% 
  filter("2021-07-01" <= DISPOSITION_DATE2, DISPOSITION_DATE2 <= "2022-06-30", !is.na(DISPOSITION))
#1716 defts/rows/records -> filter by disp date and disp code not NA

pae_1cc <-  master_1cc %>% 
  filter(INIT_DATE2 <= "2022-06-30" & (DISPOSITION_DATE2 > "2022-06-30" | is.na(DISPOSITION_DATE2)))
#1967 defts/rows/records -> filter by initiation date and disp date

#compare PAS + Filings to Terminated + PAE
tmp_before <- filed_1cc %>% 
  bind_rows(pas_1cc)

tmp_after <- terminated2_1cc %>% 
  bind_rows(pae_1cc)

before_not_in_after <- tmp_before %>% 
  anti_join(tmp_after)
#   - From inspecting before_not_in_after, discovered that there are many cases with a disposition date but no disposition code and 
#that disposition dates look incorrect
#   - The logic needs to be adjusted (see pae_1cc_adjusted) to include these in PAE

if(FALSE){
  write.csv(before_not_in_after, paste0(path_ac_files, "1CC_PC_FY22_pae_disp-date_but_no-disp-code_", Sys.Date(),".csv"))
}

pae_1cc_adjusted <-  master_1cc %>% 
  filter(INIT_DATE2 <= "2022-06-30" & (DISPOSITION_DATE2 > "2022-06-30" | is.na(DISPOSITION_DATE2) |
                                         ("2021-07-01" <= DISPOSITION_DATE2 & DISPOSITION_DATE2 <= "2022-06-30" & is.na(DISPOSITION))))
#3061 defts/rows/records -> include disps during FY22 but with DISP = NA 
#there seems to be something wrong with data extract wrt DISP and DISP DATE, spot checking shows that
#when DISP DATE is not empty but DISP is empty, the wrong DISP DATE is entered
#---------------------------------------------------------------------------------#
#RSO CASELOAD STATS----
#we have no info from RSO about criteria used, best guesses below 
#---------------------------------------------------------------------------------#
#METHOD 1: case filing date
pas_rso1 <- jps_38854_AR %>% 
  filter(INIT_DATE2 < "2021-07-01")
#9343 defts/rows/records

#METHOD 2: case filing date and initial case status
pas_rso2 <- jps_38854_AR %>% 
  filter(INIT_DATE2 < "2021-07-01", INIT_CASE_STATUS %in% c("ACTIVE", "REOPENED", "REACTIVATE", "INACTIVE"))

#METHOD 3: case filing date and recent case status
pas_rso3 <- jps_38854_AR %>% 
  filter(INIT_DATE2 < "2021-07-01", CASE_STATUS %in% c("ACTIVE", "REOPENED", "REACTIVATE", "INACTIVE"))

#METHOD 4: case status date and recent case status
pas_rso4 <- jps_38854_AR %>% 
  filter(INIT_CASE_STATUS_DATE2 < "2021-07-01", INIT_CASE_STATUS %in% c("ACTIVE", "REOPENED", "REACTIVATE", "INACTIVE"))

#METHOD 5: case status date and recent case status
pas_rso5 <- jps_38854_AR %>% 
  filter(CASE_STATUS_DATE2 < "2021-07-01", CASE_STATUS %in% c("ACTIVE", "REOPENED", "REACTIVATE", "INACTIVE"))
#7356 (method #2) -> doesn't match file from 1CC

filed_rso <- jps_38854_AR %>% 
  filter("2021-07-01" <= INIT_DATE2, INIT_DATE2 <= "2022-06-30")
#1746 -> matches file from 1CC

terminated_rso <- jps_38854_AR %>% 
  filter("2021-07-01" <= CASE_STATUS_DATE2, CASE_STATUS_DATE2 <= "2022-06-30", CASE_STATUS %in% c("CLOSEDJ", "CLOSEDS"))
#1516 -> matches file from 1CC

pae_rso <-  jps_38854_AR %>% 
  filter(INIT_DATE2 <= "2022-06-30", CASE_STATUS %in% c("ACTIVE", "REOPENED", "REACTIVATE", "INACTIVE"))
#8730 -> doesn't match file from 1CC (8206)
