# correct 資料引入沒有data tag
file.path(getwd(),"EXERCISE5","ANS")-> ansPath
listOfRMDs <- list_files_with_exts(ansPath,"RMD")

for(file_i in listOfRMDs){
  #file_i <- listOfRMDs[1]
  lines_i <- readLines(file_i)
  lines_i %>%
    str_detect("資料引入") %>%
    which -> numIndexLoc
  "```{r data1}" -> lines_i[numIndexLoc+1]  
  lines_i %>%
    str_replace_all(
      c(
        "studentID"="id",
        "studentName"="name"
      )
    )-> lines_i
  
  lines_i %>% writeLines(file_i)
  
}
