rm(list=ls())
load("~/filas20161010_final3.RData")
#save.image("~/filas20161010_final2.RData")

alunos <- alunos[!duplicated(alunos),]
duplicados <- alunos$protocolo[duplicated(alunos$protocolo)]
dupli <- alunos[(alunos$protocolo %in% duplicados),]
dupli <- dupli[order(dupli$protocolo),]
alunos <- alunos[!(alunos$protocolo %in% duplicados & alunos$nome == 'desistente'),]

p1 <- as.numeric(inscritos$protocolo)
p2 <- as.numeric(alunos$protocolo)
diff <- setdiff(p1,p2)

diff <- inscritos[pf,]

desistentes <- (alunos$protocolo[alunos$nome == "desistente"])

df.desistentes <- data.frame()

library(XML)
library(RSelenium)
checkForServer()
startServer()
remDrv <- remoteDriver(browserName = 'phantomjs')
remDrv$open()

remDrv$navigate(url_consulta)
for (protocolo in desistentes){
  remDrv$findElement(using = "xpath", "//input[@id = 'txtAlu_codigo']")$sendKeysToElement(list(protocolo))
  remDrv$findElement(using = "xpath", "//input[@id = 'btnPesquisar']")$clickElement()
  pagina <- xmlRoot(htmlParse(remDrv$getPageSource()[[1]]))
  nome <- xpathSApply(pagina, "//input[@id='txtAlu_nome']", xmlGetAttr, name = 'value')
  mae <- xpathSApply(pagina, "//input[@id='txtAlu_mae']", xmlGetAttr, name = 'value')
  nascimento <- xpathSApply(pagina, "//input[@id='txtAlu_nasc']", xmlGetAttr, name = 'value')
  if(is.null(nome[[1]])) {
    nome <- "desistente"; mae <- "desistente"; nascimento <- "desistente"
  }
  df.desistentes <- rbind(df.desistentes, data.frame(protocolo, nome, mae, nascimento))
  remDrv$findElement(using = "xpath", "//input[@id = 'btnLimpar']")$clickElement()
}

setwd("/home/acsa/creche/20161011")
write.table(alunos, "alunos20161011.csv", sep = ";", row.names = F)
write.table(inscritos, "inscritos20161011.csv", sep = ";", row.names = F)


duplicados <- inscritos$protocolo[duplicated(inscritos$protoclo)]
duplic <- inscritos[inscritos$protocolo %in% duplicados,]

#save.image("~/filas20161010_final3.RData")

inscritos2 <- inscritos[!duplicated(inscritos$protocolo),]
d <- merge(alunos, inscritos, by = "protocolo", all.x = T, all.y = F)

bf201608sp <- read.delim("~/bf201608sp.txt")
names(bf201608sp)
d <- merge(d, bf201608sp[,c(9,11)], by.x = "mae", by.y = "Nome_Favorecido", all.x = T, all.y = F)

d$bf <- 1
d$bf[is.na(d$Valor_Parcela)] <- 0
names(d)
d <- d[,]


substr(d$nascimento, 7, 10)
de <- (d[substr(d$nome, 1, 4) == "YURI" & substr(d$mae, 1, 5) == "THAIS",])
fila <- (d[d$distrito.id == 418 & d$faixa.id == "(0,1)",])
d[grepl("MONISE", d$nome),]
nasc <- (d[d$nascimento == "19/03/2016",])
head(nasc)

(table(d$faixa.id))


