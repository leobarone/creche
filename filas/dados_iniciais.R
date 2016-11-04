rm(list=ls())
setwd("~/leo/creche/filas")

load("~/leo/creche/filas/dados/filas20161010_final3.RData")
inscritos20161011 <- inscritos
desistentes <- df.desistentes
rm(list = setdiff(ls(), c("alunos", "inscritos20161011", "desistentes")))

load("~/leo/creche/filas/dados/fila20161102.RData")
atendidas20161102 <- atendidas
rm(atendidas)

load("~/leo/creche/filas/dados/fila20161024.RData")
atendidas20161024 <- atendidas
rm(atendidas)

load("~/leo/creche/filas/dados/fila20161017.RData")
atendidas20161017 <- atendidas
inscritos20161017 <- inscritos
rm(list = setdiff(ls(), c("alunos", "inscritos20161011", "desistentes", "atendidas20161017",
                          "atendidas20161102", "atendidas20161024", "inscritos20161017")))

save.image("~/leo/creche/filas/dados/primeirosDados.RData")

atendidas <- rbind(atendidas20161102, atendidas20161024, atendidas20161017)
cad_atendimentos <- atendidas[, c(1, 2, 3)]
cad_atendimentos <- cad_atendimentos[!duplicated(cad_atendimentos), ]
names(cad_atendimentos) <- c("protocolo", "data", "evento")

inscritos20161011$data.captura = " 2016-10-11 12:00:00"

inscritos20161017$data.captura = " 2016-10-17 12:00:00"

fila <- rbind(inscritos20161011, inscritos20161017)
fila <- fila[!duplicated(fila), ]
cad_inscricoes <- fila[, c(2,3)]
names(cad_inscricoes) <- c("protocolo", "data")
cad_inscricoes$evento <- "Inscricao no sistema"
cad_inscricoes <- cad_inscricoes[!duplicated(cad_inscricoes), ]

cadastro <- rbind(cad_atendimentos, cad_inscricoes)

write.table(atendidas, "~/dados/atendidas.csv", row.names = F, sep = ";")
write.table(cadastro, "~/dados/cadastro.csv", row.names = F, sep = ";")
write.table(fila, "~/dados/fila.csv", row.names = F, sep = ";")
write.table(alunos, "~/dados/alunos.csv", row.names = F, sep = ";")
write.table(desistentes, "~/dados/desistentes.csv", row.names = F, sep = ";")

