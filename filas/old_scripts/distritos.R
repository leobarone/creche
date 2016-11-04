#rm(list=ls())
library(XML)
library(RSelenium)

checkForServer()
startServer()
remDrv <- remoteDriver(browserName = 'phantomjs')
remDrv$open()

url_consulta <- "http://eolgerenciamento.prefeitura.sp.gov.br/se1426g/frmGerencial/ConsultaCandidatosCadastrados.aspx"

diretoria.id <- as.character(c(108100, 108200, 108300, 108400, 108500, 108600, 108700, 108800, 108900, 109000, 109100, 109200, 109300, 110000))

dir.dist <- data.frame()
for (id in diretoria.id){
  print(id)
  remDrv$navigate(url_consulta)
  option <-  remDrv$findElement(using = "xpath", paste0("//td//select[@name = 'cboDRE']//option[@value ='", id, "']"))
  option$clickElement()
  #Sys.sleep(0.5)
  pagina <- xmlRoot(htmlParse(remDrv$getPageSource()[[1]]))
  distrito.id <- xpathSApply(pagina, "//select[@name = 'cboSetor']//option", xmlGetAttr, name = "value")
  distrito.id <- distrito.id[2:length(distrito.id)]
  distrito.nome <- xpathSApply(pagina, "//select[@name = 'cboSetor']//option", xmlValue)
  distrito.nome <- distrito.nome[2:length(distrito.nome)]
  dir.dist <- rbind(dir.dist, data.frame(id, distrito.nome, distrito.id))  
}

faixa.id <- c("(0,1)", "(2)", "(3)", "(4)", "(5)", "(6)")
dir.dist.idade <- merge(dir.dist, faixa.id)
names(dir.dist.idade)[1] <- "diretoria.id"
names(dir.dist.idade)[4] <- "faixa.id"

dir.dist.idade <- dir.dist.idade[!is.na(dir.dist.idade$distrito.id),]
dir.dist.idade <- dir.dist.idade[dir.dist.idade$distrito.id != 0,]

save.image("distritos_creche.RData")
