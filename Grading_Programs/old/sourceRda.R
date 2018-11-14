## 要手動按行執行比較不會有問題

rm(list=ls())
params<-list(
  dirSet="./Exercise4/ans",
  hwcode="Exercise4"
)

library(tools)
library(purrr)
library(stringr)
library(dplyr)
library(knitr)
library(googlesheets)
library(readr)


dirSet<-params$dirSet
# 執行ansR的資料引入
## 清空目前env可能有和dataObjects相名稱的物作
load(paste0("./",params$hwcode,"/dataSubmitTrack.Rda"))
dataObjects %>% str_replace(" ","") ->dataObjects # 刪除名稱多餘空白
#rm(list=dataObjects)
ansR <- str_replace(ansR,"..",".")
originContent <- readLines(ansR)
lapply(dataObjects,
       function(x) {
         loc<-str_which(originContent,x)
         min(loc)
       })->dataLines
dataLines<-unlist(dataLines)
dataImportLines<- originContent[dataLines]
eval(parse(
  text=(dataImportLines)
))
# Remove everything but dataObjects
objectsToKeep<-c(dataObjects,c("dataObjects","params","listOfRsNoAns","ansR")) %>% unique %>% str_replace(" ","") # 除去不必要空白
objectsToRemove<-base::setdiff(ls(),objectsToKeep)
rm(list=objectsToRemove)

# Run R to get Rda
listOfRdas<-list_files_with_exts(params$dirSet,"Rda")
if(length(listOfRdas)>0){
  file.remove(listOfRdas)
}
library(rlang)
listOfRsNoAns %>% str_replace("..",".") -> listOfRsNoAns
listOfRs<-c(listOfRsNoAns,ansR)
validRda<-rep(F,length(listOfRs)) # 可否產生Rda

for(i in 1:length(listOfRs)){
  dataEnv <- rlang::env() # renew environment each time
  purrr::map(dataObjects,
             ~eval(parse(text=paste0("assign('",
                                     .,"',",
                                     .,",envir=dataEnv)"))))
  tryCatch(
    {
      source(listOfRs[i],dataEnv)  
      validRda[i]<-T
    },
    error=function(e){
      
    }
  ) 
}

