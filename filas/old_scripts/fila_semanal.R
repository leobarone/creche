rm(list=ls())
library(XML)
library(RSelenium)

setwd("~/creche_old")

load("distritos_creche.RData")

checkForServer()
startServer()
remDrv <- remoteDriver(browserName = 'phantomjs')
remDrv$open()

url_consulta <- "http://eolgerenciamento.prefeitura.sp.gov.br/se1426g/frmGerencial/ConsultaCandidatosCadastrados.aspx"

inscritos <- data.frame()
for (i in 1:nrow(dir.dist.idade)){
  print(i) #i = 1
  remDrv$navigate(url_consulta)
  option <-  remDrv$findElement(using = "xpath", paste0("//td//select[@name = 'cboDRE']//option[@value ='", dir.dist.idade[i, 1], "']"))
  option$clickElement()
  option <-  remDrv$findElement(using = "xpath", paste0("//td//select[@name = 'cboSetor']//option[@value ='", dir.dist.idade[i, 3], "']"))
  option$clickElement()
  option <-  remDrv$findElement(using = "xpath", paste0("//td//select[@name = 'cboFaixaEtaria']//option[@value ='", dir.dist.idade[i, 4], "']"))
  option$clickElement()
  remDrv$findElement(using = "xpath", "//input[@id = 'btnConfirmar']")$clickElement()
  pagina <- xmlRoot(htmlParse(remDrv$getPageSource()[[1]]))
  tabela <- readHTMLTable(pagina, stringsAsFactors = F)
  if (nrow(tabela) > 12){
    tabela <- tabela[13:nrow(tabela),]
    tabela <- tabela[!is.na(tabela[ ,2]),]
    names(tabela) <- c("ordem", "protocolo", "data.cadastro", "data.reativacao", "observacao")
    # tabela$observacao <- iconv(tabela$observacao)
    
    inscritos <- rbind(inscritos, data.frame(tabela, dir.dist.idade[i,]))
  }
}

inscritos$data.captura <- Sys.time()

# CHECAR URL ATENDIDA
url_atendidas <- "http://eolgerenciamento.prefeitura.sp.gov.br/se1426g/frmGerencial/ConsultaAtendidosPeriodo.aspx?Protocolo=3153945"
atendidas <- readHTMLTable(url_atendidas, stringsAsFactors = F)[[5]]
names(atendidas) <- c("protocolo", "data.atendimento", "situacao", "espera.encaminhamento")
atendidas$data.captura <- Sys.time()

nome.imagem <- paste0("fila", substr(Sys.time(), 1, 4), substr(Sys.time(), 6, 7), substr(Sys.time(), 9, 10), ".RData")
save.image(nome.imagem)
