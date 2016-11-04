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

inscritos <- data.frame()
for (i in 1:nrow(dir.dist.idade)){
  print(i)
  remDrv$navigate(url_consulta)
  option <-  remDrv$findElement(using = "xpath", paste0("//td//select[@name = 'cboDRE']//option[@value ='", dir.dist.idade[i, 1], "']"))
  option$clickElement()
  #Sys.sleep(0.5)
  option <-  remDrv$findElement(using = "xpath", paste0("//td//select[@name = 'cboSetor']//option[@value ='", dir.dist.idade[i, 3], "']"))
  option$clickElement()
  #Sys.sleep(0.5)
  option <-  remDrv$findElement(using = "xpath", paste0("//td//select[@name = 'cboFaixaEtaria']//option[@value ='", dir.dist.idade[i, 4], "']"))
  option$clickElement()
  #Sys.sleep(0.5)
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

save.image("filas_creche.RData")

protocolos <- inscritos$protocolo
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

dados <- merge(alunos, inscritos, by.x = "protocolo", by.y = "protocolo", all.x = T, all.y= F)

faixa.texto <- c("01/04/2015 a 31/12/2016", "01/04/2014 a 31/03/2015", "01/04/2013 a 31/03/2014", 
                 "01/04/2012 a 31/03/2013", "01/04/2011 a 31/12/2012", "01/04/2011 a 31/03/2010")
faixas <- data.frame(faixa.id, faixa.texto)
names(faixas)
names(dados)
dados <- merge(dados, faixas, by.x = "faixa.id", by.y = "faixa.id", all.x = T, all.y = F)

diretoria.texto <- c("DIRETORIA REGIONAL DE EDUCACAO BUTANTA",
                      "DIRETORIA REGIONAL DE EDUCACAO CAMPO LIMPO",
                      "DIRETORIA REGIONAL DE EDUCACAO CAPELA DO SOCORRO",
                      "DIRETORIA REGIONAL DE EDUCACAO FREGUESIA/BRASILANDIA",
                      "DIRETORIA REGIONAL DE EDUCACAO GUAIANASES",
                      "DIRETORIA REGIONAL DE EDUCACAO IPIRANGA",
                      "DIRETORIA REGIONAL DE EDUCACAO ITAQUERA",
                      "DIRETORIA REGIONAL DE EDUCACAO JACANA/TREMEMBE",
                      "DIRETORIA REGIONAL DE EDUCACAO PENHA",
                      "DIRETORIA REGIONAL DE EDUCACAO PIRITUBA/JARAGUA",
                      "DIRETORIA REGIONAL DE EDUCACAO SANTO AMARO",
                      "DIRETORIA REGIONAL DE EDUCACAO SAO MATEUS",
                      "DIRETORIA REGIONAL DE EDUCACAO SAO MIGUEL",
                      "GABINETE DO SECRETARIO - SME G")

diretorias <- data.frame(diretoria.id, diretoria.texto)
dados <- merge(dados, diretorias, by.x = "diretoria.id", by.y = "diretoria.id", all.x = T, all.y = F)

dados <- dados[, c(3:10, 1, 14, 12, 11, 2, 13)]
names(dados)

save.image("filas20161010.RData")

#load("filas20161010_parcial.RData")

library(XML)
library(RSelenium)
checkForServer()
startServer()
remDrv <- remoteDriver(browserName = 'phantomjs')
remDrv$open()

j = nrow(alunos) + 1
remDrv$navigate(url_consulta)
for (protocolo in protocolos[j:length(protocolos)]){
  print(j); j = j + 1
  remDrv$findElement(using = "xpath", "//input[@id = 'txtAlu_codigo']")$sendKeysToElement(list(protocolo))
  remDrv$findElement(using = "xpath", "//input[@id = 'btnPesquisar']")$clickElement()
  pagina <- xmlRoot(htmlParse(remDrv$getPageSource()[[1]]))
  nome <- xpathSApply(pagina, "//input[@id='txtAlu_nome']", xmlGetAttr, name = 'value')
  mae <- xpathSApply(pagina, "//input[@id='txtAlu_mae']", xmlGetAttr, name = 'value')
  nascimento <- xpathSApply(pagina, "//input[@id='txtAlu_nasc']", xmlGetAttr, name = 'value')
  if(is.null(nome[[1]])) {
    nome <- "desistente"; mae <- "desistente"; nascimento <- "desistente"
  }
  alunos <- rbind(alunos, data.frame(protocolo, nome, mae, nascimento))
  remDrv$findElement(using = "xpath", "//input[@id = 'btnLimpar']")$clickElement()
}

save.image(paste0("filas20161010_", (j - 2) ,".RData"))
