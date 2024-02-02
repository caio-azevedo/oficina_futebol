rm(list=ls())

url <- c("https://api.gcn.ge.globo.com/api/rotatividade-dos-tecnicos/vinculos/clubes?page=1&per_page=10",
         "https://api.gcn.ge.globo.com/api/rotatividade-dos-tecnicos/vinculos/clubes?page=2&per_page=10",
         "https://api.gcn.ge.globo.com/api/rotatividade-dos-tecnicos/vinculos/clubes?page=3&per_page=10")

df <- list()

for (i in c(1:3)) {

  tecnico <- GET(url[i])

  lista_tec <- content(tecnico, simplifyDataFrame = TRUE)

  num_tec <- unlist(lapply(
    lista_tec[["equipes"]][["vinculos"]],
    function(df) nrow(df)))

  equipes <- lista_tec[["equipes"]][["equipe"]][["nome_popular"]]

  df[[i]] <- dplyr::bind_rows(lista_tec[["equipes"]][["vinculos"]]) |>
    dplyr::mutate(clube = rep(equipes, num_tec))
}


base <- dplyr::bind_rows(df)
