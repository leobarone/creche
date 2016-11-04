rm(list=ls())
library(XML)

url_atendidas <- "http://eolgerenciamento.prefeitura.sp.gov.br/se1426g/frmGerencial/ConsultaAtendidosPeriodo.aspx?Protocolo=3153945"
atendidas <- readHTMLTable(url_atendidas, stringsAsFactors = F)[[5]]
names(atendidas) <- c("protocolo", "data.atendimento", "situacao", "espera.encaminhamento")
atendidas$data.captura <- Sys.time()

protocolos <- atendidas$protocolo

library(RSelenium)
checkForServer()
startServer()
remDrv <- remoteDriver(browserName = 'phantomjs')

remDrv$open()
url_consulta <- "http://eolgerenciamento.prefeitura.sp.gov.br/se1426g/frmGerencial/ConsultaPosicaoIndividual.aspx"
alunos <- data.frame()

j = 1
for (protocolo in protocolos){
  print(j); j = j + 1
  remDrv$navigate(url_consulta)
  remDrv$findElement(using = "xpath", "//input[@id = 'txtAlu_codigo']")$sendKeysToElement(list(protocolo))
  remDrv$findElement(using = "xpath", "//input[@id = 'btnPesquisar']")$clickElement()
  pagina <- xmlRoot(htmlParse(remDrv$getPageSource()[[1]]))
  nome <- xpathSApply(pagina, "//input[@id='txtAlu_nome']", xmlGetAttr, name = 'value')
  mae <- xpathSApply(pagina, "//input[@id='txtAlu_mae']", xmlGetAttr, name = 'value')
  nascimento <- xpathSApply(pagina, "//input[@id='txtAlu_nasc']", xmlGetAttr, name = 'value')
  alunos <- rbind(alunos, data.frame(protocolo, nome, mae, nascimento))
}


save.image("atendidas20161017.RData")

