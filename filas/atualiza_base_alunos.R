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

write.table(alunos, "alunos.csv", row.names = F, sep = ";")
# Recomecar aqui




