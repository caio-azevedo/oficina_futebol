rm(list=ls())

url <- "https://raw.githubusercontent.com/williamorim/brasileirao/master/data-raw/csv/matches.csv"
dados <- readr::read_csv(url)

# Trabalhando o "score" ---------------------------------------------------

gols_mandante <- substr(dados$score,start = 1, stop = 1)
gols_visitante <- substr(dados$score,start = 3, stop = 3)
tabela1 <- cbind(dados, gols_mandante, gols_visitante) # empilhar colunas
tabela1 <- subset(tabela1, select = -c(score)) # excluir coluna

# Tornando as novas variáveis em numéricas --------------------------------

tabela1$gols_mandante <- as.numeric(tabela1$gols_mandante)
tabela1$gols_visitante <- as.numeric(tabela1$gols_visitante)

# Criando a coluna de pontos ----------------------------------------------

tabela1$pontos_mandante <- ifelse(gols_mandante > gols_visitante, 3 ,
                                  ifelse(gols_mandante == gols_visitante,1, 0))

tabela1$pontos_visitante <- ifelse(gols_mandante > gols_visitante, 0 ,
                                   ifelse(gols_mandante == gols_visitante,1, 3))

# Reordenando as colunas --------------------------------------------------

tabela1 <- subset(tabela1, select = c(id_match, season, date,
                                      home, pontos_mandante,
                                      gols_mandante, away,
                                      pontos_visitante,
                                      gols_visitante))

# Duplicando as linhas ----------------------------------------------------

aux_mandante <- cbind(tabela1,mando=c("mandante"))
aux_visitante <- cbind(tabela1,mando=c("visitante"))
tabela1 <- rbind(aux_mandante,aux_visitante)
tabela1 <- tabela1[order(tabela1$id_match, tabela1$mando),]
rownames(tabela1) <- NULL

# Criando as colunas time e adversario ------------------------------------

time <- ifelse(tabela1$mando=="mandante",tabela1$home,
               tabela1$away)
adversario <- ifelse(tabela1$mando=="visitante",tabela1$home,
                     tabela1$away)
tabela1$home <- time
tabela1$away <- adversario

# Renomeando as colunas time e adversario ---------------------------------

colnames(tabela1)[colnames(tabela1)=="home"] <- "time"
colnames(tabela1)[colnames(tabela1)=="away"] <- "adversario"

# Criando as colunas gols_favor e gols_contra -----------------------------

gols_favor <- ifelse(tabela1$mando=="mandante", tabela1$gols_mandante,
                     tabela1$gols_visitante)
gols_contra <- ifelse(tabela1$mando=="visitante", tabela1$gols_mandante,
                      tabela1$gols_visitante)
tabela1$gols_mandante <- gols_favor
tabela1$gols_visitante <- gols_contra

# Renomeando as colunas gols_favor e gols_contra --------------------------

colnames(tabela1)[colnames(tabela1)=="gols_mandante"] <- "gols_favor"
colnames(tabela1)[colnames(tabela1)=="gols_visitante"] <- "gols_contra"

# Criando a variável pontos -----------------------------------------------

pontos <- ifelse(tabela1$mando=="mandante",tabela1$pontos_mandante,
                 tabela1$pontos_visitante)
tabela1$pontos_mandante <- pontos
colnames(tabela1)[colnames(tabela1)=="pontos_mandante"] <- "pontos"
tabela1 <- subset(tabela1, select = -c(pontos_visitante))

# Criando a coluna da rodada ----------------------------------------------

tabela1 <- tabela1[order(tabela1$season, tabela1$time,
                         tabela1$date),]

