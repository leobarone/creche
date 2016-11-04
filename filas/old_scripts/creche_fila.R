rm(list=ls())
library(XML)

# URL Base para consulta
urlbase <- "http://eolgerenciamento.prefeitura.sp.gov.br/se1426g/frmGerencial/ConsultaCandidatosCadastrados.aspx?Protocolo=ABCDE&TipoPesquisa=P"

# Funcao obter tabela a partir de URL
tabela.inscritos <- function(url){
  tabelas <- readHTMLTable(url, stringsAsFactors = F)
  tabela <- tabelas[[5]]
  tabela <- tabela[!is.na(tabela$Protocolo),]
  names(tabela) <- c("ordem", "protocolo", "data.cadastro", "data.reativacao", "observacao")
  tabela$observacao <- iconv(tabela$observacao)
  return(tabela)
}

# Funcao obter informacoes da dre, distrito e faixa etaria
info.fila <- function(url){
  erro <- try(page <- xmlRoot(htmlParse(readLines(url))), silent = T)
  if (!('try-error' %in% class(erro))){
    dre <- xpathSApply(page, "//table//td//select[@id = 'cboDRE']/option[@selected]", xmlValue)
    distrito <- xpathSApply(page, "//table//td//select[@id = 'cboSetor']/option[@selected]", xmlValue)
    faixa <- xpathSApply(page, "//table//td//select[@id = 'cboFaixaEtaria']/option[@selected]", xmlValue)
    return(data.frame(dre, distrito, faixa, stringsAsFactors = F))
  }
}

# Arquivo de filas
filas.creche <- read.csv("~/creche/creche/filas.creche.csv", sep=";")
names(filas.creche)[3] <- "faixa"
filas.creche$id <- paste(filas.creche$dre, filas.creche$distrito, filas.creche$faixa)

# Comecar de qualquer numero e avancar ate um numero alto a partir do ultimo
# numero em cada tabela + 1

i <- 4292828
# n <- 2000

inscritos <- data.frame()
filas <- data.frame()
while(nrow(filas.creche) > 0){
  print(nrow(filas.creche))
  url <- gsub("ABCDE", i, urlbase)
  fila <- info.fila(url)
  if (!is.null(fila)){
    fila$id <- paste(fila$dre, fila$distrito, fila$faixa)
    if (!(fila$id %in% filas$id)){
      
      filas <- rbind(filas, fila)
      
      tabela <- data.frame(tabela.inscritos(url), 'horario.coleta' = Sys.time())
      inscritos <- rbind(inscritos, merge(tabela, fila))
      
      filas.creche <- filas.creche[!(filas.creche$id == as.character(fila$id)), ]
    }
  }
  i <- i - 1
} 
beep()

write.table(inscritos, "inscritos.csv", row.names = F, sep = ";")

protocolos <- inscritos$protocolo

library(RSelenium)
checkForServer()
startServer()
remDrv <- remoteDriver(browserName = 'firefox')

# Recomecar aqui
remDrv$open()
url_consulta <- "http://eolgerenciamento.prefeitura.sp.gov.br/se1426g/frmGerencial/ConsultaPosicaoIndividual.aspx"
alunos <- data.frame()

for (protocolo in protocolos){
  print(protocolo)
  remDrv$navigate(url_consulta)
  remDrv$findElement(using = "xpath", "//input[@id = 'txtAlu_codigo']")$sendKeysToElement(list(protocolo))
  remDrv$findElement(using = "xpath", "//input[@id = 'btnPesquisar']")$clickElement()
  pagina <- xmlRoot(htmlParse(remDrv$getPageSource()[[1]]))
  nome <- xpathSApply(pagina, "//input[@id='txtAlu_nome']", xmlGetAttr, name = 'value')
  mae <- xpathSApply(pagina, "//input[@id='txtAlu_mae']", xmlGetAttr, name = 'value')
  nascimento <- xpathSApply(pagina, "//input[@id='txtAlu_nasc']", xmlGetAttr, name = 'value')
  alunos <- rbind(alunos, data.frame(protocolo, nome, mae, nascimento))
}
beep()

alunos <- cbind(protocolos[1:nrow(alunos)], alunos)
amostra <- merge(alunos, inscritos, by.x = "protocolo", by.y = "protocolo", all.x = T, all.y= F)

write.table(amostra, "amostra_creche.csv", row.names = F, sep = ";")

# Comecar de qualquer numero e avancar ate um numero alto a partir do ultimo
# numero em cada tabela + 1
#4341640
# seed.inscricao <- 4341642
# n <- 1000
# 
# inscritos <- data.frame()
# filas <- data.frame()
# 
# for (i in seed.inscricao:(seed.inscricao - n)){
#   print(i)
#   url <- gsub("ABCDE", i, urlbase)
#   fila <- info.fila(url)
#   if (!is.null(fila)){
#     fila$id <- paste(fila$dre, fila$distrito, fila$faixa)
#     if (!(fila$id %in% filas$id)){
#       filas <- rbind(filas, fila)
#     }
#   }
# }
# 
# distritos <- filas[,1:2]
# distritos <- distritos[!duplicated(distritos),]
# distritos <- distritos[order(distritos$distrito),]
# distritos <- distritos[order(distritos$dre),]
# 
# faixas <- unique(filas$faixa)
# 
# filas.completo <- merge(distritos, faixas)
# 
# write.table(filas.completo, "filas.creche.csv", row.names = F, sep = ";")
