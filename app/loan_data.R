#Graph of borrowing numbers----
##Download dataset of all loans
loan_data_leeds <- data.table::fread("https://datamillnorth.org/download/library-loans-all-media/84258a11-70ce-4764-82f6-184d96753e77/Library%20Loans%20-%20All%20Media.csv", na.strings = "N/A") %>%
#Gather into tidy format
  tidyr::gather(year, loans, -Issues) %>%
  dplyr::rename(library = Issues) %>%
#Clean year figures
  dplyr::mutate(year = gsub("-[[:digit:]][[:digit:]]", "", year)) %>%
  dplyr::mutate(region = "Leeds")

#Newcastle data
loan_data_newcastle <- data.table::fread("https://datamillnorth.org/download/ncclibs-loans/d79898cc-5317-4c83-b674-7223700892c1/2008-onwards-monthly-issues-by-branch.csv") %>%
#Gather into tidy format
  tidyr::gather(year, loans, -Library) %>%
  dplyr::rename(library = Library) %>%
  #Clean year figures
  dplyr::mutate(year = gsub("-[[:digit:]][[:digit:]]", "", year)) %>%
  #Summarise by year only
  dplyr::group_by(library, year) %>%
  dplyr::summarise(loans = sum(loans, na.rm = TRUE)) %>%
  dplyr::mutate(region = "Newcastle")

#Join data sets
loan_data_all <- bind_rows(loan_data_leeds, loan_data_newcastle) %>%
  dplyr::filter(year > 2007)

