rm(list=ls())

library(tidyverse)

url <- "https://raw.githubusercontent.com/williamorim/brasileirao/master/data-raw/csv/matches.csv"
dados <- readr::read_csv(url)

# Trabalhando o "score" ---------------------------------------------------

tabela2 <- dados |>
  tidyr::separate_wider_delim(
    cols = score,
    delim = "x",
    names = c("gols_mandante", "gols_visitante")) |>

# Tornando as novas variáveis em numéricas --------------------------------

  dplyr::mutate(gols_mandante = as.numeric(gols_mandante),
                gols_visitante = as.numeric(gols_visitante)) |>

# Criando a coluna de pontos ----------------------------------------------

  dplyr::mutate(pontos_mandante = dplyr::case_when(
    gols_mandante > gols_visitante ~ 3,
    gols_mandante == gols_visitante ~ 1,
    TRUE ~ 0), .after = home) |>
  dplyr::mutate(pontos_visitante = dplyr::case_when(
    gols_mandante > gols_visitante ~ 0,
    gols_mandante == gols_visitante ~ 1,
    TRUE ~ 3), .after = away) |>

# Reordenando as colunas --------------------------------------------------

  dplyr::relocate(gols_visitante, .after = pontos_visitante) |>

# Duplicando as linhas ----------------------------------------------------

  tidyr::pivot_longer( cols = c(pontos_mandante, pontos_visitante),
                       names_to = "mando", values_to = "pontos") |>
  dplyr::mutate(mando = stringr::str_remove(mando, "pontos_")) |>

# Criando as colunas time e adversario ------------------------------------

  dplyr::mutate(time = ifelse(mando == "mandante",home,away),
                adversario = ifelse(mando == "mandante",away,home),
                .after = date) |>
  dplyr::select(-c(home,away)) |>

# Criando as colunas gols_favor e gols_contra -----------------------------

  dplyr::mutate(gols_favor = ifelse(mando == "mandante", gols_mandante,
                                    gols_visitante),
                gols_contra = ifelse(mando == "mandante", gols_visitante,
                                     gols_mandante)) |>
  dplyr::select(-c(gols_mandante, gols_visitante)) |>


# Criando a coluna rodada -------------------------------------------------

dplyr::arrange(season, time, date) |>
  dplyr::group_by(season, time) |>
  dplyr::mutate(
    rodada = dplyr::row_number(),
    .after = season
  ) |>

# Criando a coluna pontos acumulado ---------------------------------------

dplyr::mutate(pontos_acum = case_when(time == lag(time,
                        default = first(time)) ~ cumsum(pontos),
                        TRUE ~ pontos)) |>

# Criando a coluna gols a favor acumulado ---------------------------------

dplyr::mutate(gp_acum = case_when(time == lag(time,
                                  default = first(time)) ~ cumsum(gols_favor),
                                  TRUE ~ gols_favor)) |>


# Criando a coluna gols contra acumulado ----------------------------------

dplyr::mutate(gc_acum = case_when(time == lag(time,
                                              default = first(time)) ~
                                    cumsum(gols_contra),
                                  TRUE ~ gols_contra)) |>

# Criando as colunas vitória e números de vitória ------------------------------------------------

dplyr::mutate(vitoria = ifelse(pontos==3,1,0),.before = pontos) |>
  dplyr::mutate(num_vit = case_when(time==lag(time, default = first(time)) ~
    cumsum(vitoria), TRUE ~ vitoria)) |>

# Criando as colunas de saldo e saldo acumulado ---------------------------

dplyr::mutate(saldo = gols_favor - gols_contra, .before = pontos_acum) |>
  dplyr::mutate(saldo_acum= case_when(time==lag(time, default = first(time)) ~
    cumsum(saldo), TRUE ~ saldo)) |>

# Criando a coluna colocação ----------------------------------------------

  dplyr::group_by(season) |>
  dplyr::arrange(desc(season), rodada,
                 desc(pontos_acum),
                 desc(num_vit),
                 desc(saldo_acum),
                 desc(gp_acum))

  tabela2 <- tabela2 |>
  dplyr::group_by(season,rodada)

tabela2$duplicada <-  duplicated.data.frame(tabela2[,c(13:17)])

tabela2 <- tabela2 |>
  dplyr::mutate(colocacao = ifelse(duplicada==FALSE,
                                   dplyr::row_number(),
                                   lag(row_number())))
