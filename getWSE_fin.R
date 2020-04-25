

getWSE_fin <- function(tickers,
                         fin_var,
                         from = "1991-04-16",
                         to = Sys.Date(),
                         freq ){
  
  # checking dependencies and loading libraries
  required_packages <- c("lubridate", "dplyr", "stringr")
  
  if(any(!(required_packages %in% installed.packages()[,"Package"]))){ 
    stop(paste("Required packages are not installed on local PC:", 
               required_packages[which(!(required_packages %in% installed.packages()[,"Package"]))]))
  }
  
  library(dplyr)
  
  tickers <- paste(tickers, fin_var, sep = "_")
  
  # change date format to character yyyymmdd
  from_d <- as.character(from)%>%
    stringr::str_remove_all("-")
  to_d <- as.character(to)%>%
    stringr::str_remove_all("-")
  
  # frequency
  if(freq == "daily" | freq == "pub")     fr <- "d"
  if(freq == "weekly")    fr <- "w"
  if(freq == "monthly")   fr <- "m"
  if(freq == "quarterly") fr <- "q"
  if(freq == "yearly")    fr <- "y"
  
  
  # full url to download data
  url.caly <- paste("https://stooq.pl/q/d/l/?s=", tickers[1],
                    "&d1=", from_d,
                    "&d2=", to_d,
                    "&i=", fr,
                    sep = "")
  
  total <- read.csv(url.caly,
                    header = TRUE,
                    sep = ",",
                    dec = ".",
                    stringsAsFactors = F)
  
  total$Data <- lubridate::ymd(total$Data) 
  total <- select(total, Data,  Zamkniecie)
  colnames(total) <- c("Data", tickers[1])
  
  # if there is only one ticker to download, then retunred data frame consists of OHLC and vloume
  if(length(tickers)  > 1)
  { 
    
    progress.bar <- winProgressBar(title = "Downloading data, Done in %,
                                 0% Done", 0, 100, 0) 
    for(i in 2:length(tickers))
    {
      
      url.caly <- paste("https://stooq.pl/q/d/l/?s=", tickers[i],
                        "&d1=", from_d,
                        "&d2=", to_d,
                        "&i=", fr,
                        sep = "")
      
      stock <- read.csv(url.caly,
                        header = TRUE,
                        sep = ",",
                        dec = ".",
                        stringsAsFactors = F) 
      
      stock$Data <- lubridate::ymd(stock$Data)
      stock <- select(stock, Data,  Zamkniecie)
      colnames(stock) <- c("Data", tickers[i]) 
      
      total <- merge(total,stock,by="Data",all=TRUE)
      
      percentage <- i / length(tickers)
      setWinProgressBar(progress.bar, percentage, "Downloading stocks - Done in %",
                        sprintf("%i%% Done", round(100 * percentage)))
    }
    close(progress.bar)
  }
  return(total)
}

# fin_data <- getWSE_fin(tickers = c("dkr", "ccc", "peo", "gwr"),
#                       fin_var = "mv", 
#                       from = "2015-01-01",
#                       freq = "daily")

df <- getWSE_fin(tickers = c("dkr", "ccc", "peo", "clc"),
                                             fin_var = "mv", 
                                              from = "2015-01-01",
                                              freq = "daily")
