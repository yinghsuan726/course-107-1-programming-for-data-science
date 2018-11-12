gsAllInfo <- gs_key(params$gsAllInfo)
gradeWS <- gs_read(gsAllInfo,ws="作業成績")

# 作業都沒交
# gradeWS %>% 
#   select(-c(1:4)) %>%
#   mutate_all(
#     funs(
#       is.na(.)
#     )
#   ) %>%
#   {rowSums(.)} %>%
#   {.==3} -> gradeWS$都沒交

# gradeWS %>% 
#   gs_edit_cells(gsAllInfo,ws="作業成績",
#                 input=.,
#                 anchor="A1")

gsLala <- gs_key("1mC9bnxj11NCNoOCw0Vmn4nxERbHtLjeGo9v9C9b2GDE")

lalaWS <- gs_read(gsLala,ws="Form Responses 1")

gradeWS %>% 
  filter(學號 %in% lalaWS$學號) %>% #只留下有填課堂問卷的
  left_join(
    lalaWS %>% 
      select(學號,本學期目前已參加之課外活動), 
    by="學號") %>%
  mutate(有啦啦=本學期目前已參加之課外活動 %>% 
                        str_detect("啦啦隊")) %>%
  select(姓名,學號,信箱,都沒交,有啦啦) -> resultWS

# 有填課堂問卷的人中，參加啦啦隊/交作業狀況
resultWS %>% 
  {table(.$都沒交,.$有啦啦,dnn=c("都沒交","有啦啦"))} %>%
  prop.table(margin=2) 

# 其他參與都沒有的
gs_read(gsAllInfo,ws="成績") -> allgradeWS
allgradeWS %>%
  select(-c(1:6)) %>%
  {rowSums(.,na.rm=T)} -> allgradeWS$公告及練習

allgradeWS$公告及練習 %>% 
  {.==0} %>%
  sum(.,na.rm=T) 

allgradeWS %>%
  left_join(
    gradeWS %>% 
      select(學號,都沒交),
    by="學號") -> allgradeWS

# 沒看公告沒來上課：有12人
allgradeWS %>%
{table(.$公告及練習==0,.$都沒交,
       dnn=c("沒公練","沒交作業"))}->tb1
tb1

# 排除一開始就沒看公告沒上課的人
allgradeWS %>%
  filter(公告及練習!=0, 
        str_sub(as.character(學號),2,4)=="107") -> validSample
validSample  %>% # 取出有填問卷
  filter(學號 %in% lalaWS$學號) %>%
  left_join(
    lalaWS %>% mutate(
      lala=(本學期目前已參加之課外活動 %>%
                           str_detect("啦啦"))
    ) %>%
      select(學號,lala),by="學號"
  ) -> allgradeDoParticipateWS

allgradeDoParticipateWS %>%
{table(.$公告及練習,.$lala)} -> tb2
tb2  
tb2 %>% prop.table(.,margin=2) -> proptb2

allgradeDoParticipateWS %>%
{table(.$都沒交,.$lala)} -> tb3
tb3
tb3 %>% prop.table(.,margin=2) -> proptb3
proptb3

allgradeDoParticipateWS %>%
  left_join(
    gradeWS %>%
      select(學號,hw1,hw2,Exercise3),
    by="學號"
  ) -> allgradeDoParticipateWS

allgradeDoParticipateWS %>%
  select(hw1,hw2,Exercise3) %>% #mark有/無交作業
  mutate_all(
    funs(
      !is.na(.)
    )
  ) %>% #計算交作業次數
  {rowSums(.)} -> allgradeDoParticipateWS$交作業次數

allgradeDoParticipateWS %>%
{table(.$交作業次數,.$lala)} -> tb4
tb4
tb4 %>% prop.table(.,margin=2) -> proptb4
proptb4

allgradeDoParticipateWS %>%
  select(hw1,hw2,Exercise3) %>% 
  {rowMeans(.,na.rm = T)} -> allgradeDoParticipateWS$平均作業分數

allgradeDoParticipateWS %>%
  group_by(lala) %>%
  summarise(平均得分=mean(平均作業分數,na.rm = T)) -> hwGradeLala
