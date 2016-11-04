inscricoes <- read.csv("~/leo/creche/inscricoes.csv", sep=";")
novas_inscricoes <- setdiff(inscritos$protocolo, inscricoes$protocolo)
inscricoes <- rbind(inscricoes, inscritos[inscritos$protocolo %in% novas_inscricoes, ])
write.table(inscricoes, "inscricoes.csv", row.names = F, sep = ";")

atendimentos <- read.csv("~/leo/creche/filas/dados/atendimentos.csv", sep=";")
cadastro <- read.csv("~/leo/creche/filas/dados/cadastro.csv", sep=";")
inscricoes <- read.csv("~/leo/creche/filas/dados/inscricoes.csv", sep=";")

novas_inscricoes <- setdiff(inscritos$protocolo, inscricoes$protocolo)
inscricoes <- rbind(inscricoes, inscritos[inscritos$protocolo %in% novas_inscricoes, c(2,3)])

novos_atendimentos <- setdiff(atendidas$protocolo, atendimentos$protocolo)
atendimentos <- rbind(atendimentos, atendidas[atendidas$protocolo %in% novos_atendimentos, c(1, 2, 3)])

cadastro <- rbind(cadastro,
                  data.frame(protocolo = unique(setdiff(novos_cadastro$protocolo, inscricoes$protocolo)), 
                             situacao = "inscrita"))

write.table(atendimentos, "atendimentos.csv", row.names = F, sep = ";")
write.table(inscricoes, "inscricoes.csv", row.names = F, sep = ";")
write.table(cadastro, "cadastro.csv", row.names = F, sep = ";")