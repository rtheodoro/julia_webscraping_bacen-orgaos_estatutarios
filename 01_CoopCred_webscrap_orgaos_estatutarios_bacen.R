################################################################################.
################################################################################.
#             Dados de órgãos estatutários das coooperativas de crédito        #
#                                                                              #
# Os arquivos serão baixados do endereço:                                      #
# https://www.bcb.gov.br/estabilidadefinanceira/encontreinstituicao            #
#                                                                              #
#                                                                              #
################################################################################.
################################################################################.

setwd(here::here())

# Packages ----
library(magrittr)


# data da coleta ----------------------------------------------------------
datacoleta <- format(Sys.time(), "%Y%m")

# Baixando CSV com CNPJ das Coopcred que possuem informações ----
# Url do CSV
u_bc_csv <- "https://www3.bcb.gov.br/informes/rest/pessoasJuridicas/csv?seg=9&age=true"



# local para salvar os arquivos
caminho <- glue::glue("dados/{datacoleta}")

# Criando pasta destino
if (file.exists(caminho)) {
   cat("A pasta já existe")
} else {
   dir.create(caminho)
   cat("Pasta criada.")
}

dest_file <- glue::glue("{caminho}/{datacoleta}_cnpj_coopcred.csv")

httr::GET(u_bc_csv, httr::write_disk(dest_file, overwrite = TRUE))

# Verifique se o arquivo foi baixado com sucesso
if (file.exists(dest_file)) {
   cat("O arquivo foi baixado com sucesso.")
} else {
   cat("Houve um problema ao baixar o arquivo.")
}

# Tratando csv baixado ----------------------------------------------------

# Verifique que podem haver cooperativas de crédito sem cnpj!!!!!!
# não sei o motivo, não encontrei o cnpj

cnpj_coopcred <-
   read.csv(
      glue::glue("{caminho}/{datacoleta}_cnpj_coopcred.csv"),
      sep = ";",
      skip = 7
   ) |>
   janitor::clean_names() |>
   dplyr::select(cnpj) |>
   dplyr::filter(!is.na(cnpj))


# Baixando informações estatutarias ----
cnpj <- c(cnpj_coopcred$cnpj)

# * Carrega df Vazios ----
info_gerais_coop  <- data.frame()
comite_auditoria_coop <- data.frame()
estrutura_governanca <- data.frame()
auditor_independente_coop <- data.frame()
numero_de_agencias_coop <- data.frame()


# ** Informacoes gerais ----
i <- 0


for(i in 1:length(cnpj)){
   
   print(paste0("CNPJ ",cnpj[i]," --- ",i," de ",length(cnpj)))  
   
   dcoop <- jsonlite::fromJSON(paste0("https://www3.bcb.gov.br/informes/rest/pessoasJuridicas?cnpj=", cnpj[i], ""))
   
   print(paste0("CNPJ ",cnpj[i]," Info. Gerais")) 
   
   info_gerais_coop_i <- dcoop %>% purrr::pluck(., "cnpj") %>%
      as.data.frame() %>%
      data.table::setnames(".", "cnpj") %>%
      dplyr::mutate(
         nome_coop = purrr::pluck(dcoop, "nome", .default = NA),
         naturezaJuridica = purrr::pluck(dcoop, "naturezaJuridica", .default = NA),
         classe = purrr::pluck(dcoop, "classeCooperativa", "nome", .default = NA),
         situacao = purrr::pluck(dcoop, "situacao", .default = NA),
         regimeEspecial = purrr::pluck(dcoop, "regimeEspecial", .default = NA),
         logradouro = purrr::pluck(dcoop, "endereco", "logradouro", .default = NA),
         complemento = purrr::pluck(dcoop, "endereco", "complemento", .default = NA),
         bairro = purrr::pluck(dcoop, "endereco", "bairro", .default = NA),
         municipio = purrr::pluck(dcoop, "endereco", "municipio", "nome", .default = NA),
         uf = purrr::pluck(dcoop, "endereco", "municipio", "siglaEstado", .default = NA),
         cep = purrr::pluck(dcoop, "endereco", "cep", .default = NA),
         endereco_eletronico = purrr::pluck(dcoop, "endereco", "enderecoEletronico", .default = NA),
         email = purrr::pluck(dcoop, "endereco", "email", .default = NA),
         telefone_ddd = purrr::pluck(dcoop, "telefone", "ddd", .default = NA),
         telefone_numero = purrr::pluck(dcoop, "telefone", "numero", .default = NA),
         segmento_prudencial = purrr::pluck(dcoop, "segmentoPrudencial", .default = NA),
         ato_presi = purrr::pluck(dcoop, "atoPresi", .default = NA),
         nome_Liquidante = purrr::pluck(dcoop, "nomeLiquidante", .default = NA),
         filiacao = purrr::pluck(dcoop, "filiacao", .default = NA),
         filiacao_central = purrr::pluck(dcoop, "filiacaoCooperativaCentral", .default = NA),
      ) %>%
      dplyr::select(cnpj, nome_coop, everything()) 
   
   if (exists("info_gerais_coop_i")){
      if (nrow(info_gerais_coop)==0){
         info_gerais_coop <- info_gerais_coop_i
      } else {
         info_gerais_coop <- info_gerais_coop %>% rbind(info_gerais_coop_i)
         rm(info_gerais_coop_i)
      }
   } else {
      print("Faz nada")
   }
   
   print(paste0("CNPJ ",cnpj[i]," Comitê de auditoria")) 
   
   ifelse(!is.null(purrr::pluck(dcoop,  "orgaos", "administradores", 1)),
          comite_auditoria_coop_i <- dcoop %>% purrr::pluck(., "orgaos", "administradores", 1) %>% 
             dplyr::mutate(cnpj = purrr::pluck(dcoop, "cnpj"),
                           nome_coop = purrr::pluck(dcoop, "nome")) %>% 
             dplyr::select(cnpj, nome_coop, everything(), -id),
          print("Vazio"))
   
   if (exists("comite_auditoria_coop_i")){
      if (nrow(comite_auditoria_coop)==0){
         comite_auditoria_coop <- comite_auditoria_coop_i
      } else {
         comite_auditoria_coop <- comite_auditoria_coop %>% rbind(comite_auditoria_coop_i)
         rm(comite_auditoria_coop_i)
      }
   } else {
      print("Faz nada")
   }
   
   print(paste0("CNPJ ",cnpj[i]," Estrutura de governança")) 
   
   if (!is.null(purrr::pluck(dcoop,
                             "orgaos",
                             "administradores",
                             1))) {
      for (j in 1:length(unique(dcoop$orgaos$administradores))) {
         estrutura_governanca_j <- dcoop %>%
            purrr::pluck(.,
                         "orgaos",
                         "administradores",
                         as.numeric(j)) %>%
            dplyr::mutate(
               cnpj = purrr::pluck(dcoop, "cnpj"),
               nomec = purrr::pluck(dcoop, "nome"),
               orgao = purrr::pluck(dcoop, "orgaos", 2, j)
            ) %>%
            dplyr::select(cnpj, nomec, everything(),-id)
         
         estrutura_governanca <-
            estrutura_governanca %>% rbind(estrutura_governanca_j)
         
         rm(estrutura_governanca_j)
         
         print(j)
         
      }
      rm(j)
      
   } else {
      
      print("Sem órgão de governança, possivelmente confederacao")
      
   }
   
   print(paste0("CNPJ ",cnpj[i]," Número de Agências")) 
   
   ifelse(!is.null(purrr::pluck(dcoop, "numeroAgencias")),  
          numero_de_agencias_coop_i <- dcoop %>% purrr::pluck(., "numeroAgencias") %>% 
             as.data.frame() %>% 
             data.table::setnames(".","numeroAgencias") %>% 
             dplyr::mutate(cnpj = purrr::pluck(dcoop, "cnpj"),
                           nome_coop = purrr::pluck(dcoop, "nome")) %>% 
             dplyr::select(cnpj, nome_coop, everything()),
          print("Vazio"))
   
   
   if (exists("numero_de_agencias_coop_i")){
      if (nrow(numero_de_agencias_coop)==0){
         numero_de_agencias_coop <- numero_de_agencias_coop_i
      } else {
         numero_de_agencias_coop <- numero_de_agencias_coop %>% rbind(numero_de_agencias_coop_i)
         rm(numero_de_agencias_coop_i)
      }
   } else {
      print("Faz nada")
   }
   
   print(paste0("CNPJ ",cnpj[i]," Auditor Independente")) 
   
   ifelse(
      !is.null(purrr::pluck(dcoop, "auditorIndependente")),
      auditorIndependente_i <-
         dcoop %>% purrr::pluck(., "auditorIndependente") %>%
         as.data.frame() %>%
         data.table::setnames(".", "auditorIndependente") %>%
         dplyr::mutate(
            cnpj = purrr::pluck(dcoop, "cnpj"),
            nome_coop = purrr::pluck(dcoop, "nome")
         ) %>%
         dplyr::select(cnpj, nome_coop, everything()),
      print("Vazio")
   )
   
   if (exists("auditorIndependente_i")){
      if (nrow(auditor_independente_coop)==0){
         auditor_independente_coop <- auditorIndependente_i
      } else {
         auditor_independente_coop <- auditor_independente_coop %>% rbind(auditorIndependente_i)
         rm(auditorIndependente_i)
      }
   } else {
      print("Faz nada")
   }
   
};rm(i)

write.csv(info_gerais_coop, glue::glue("{caminho}/{datacoleta}_CoopCred_BCB_info_gerais.csv"), row.names = FALSE)
write.csv(comite_auditoria_coop, glue::glue("{caminho}/{datacoleta}_CoopCred_BCB_comite_auditoria.csv"), row.names = FALSE)

estrutura_governanca |> dplyr::count(orgao) # Verirficar conselhos
###### adicionar coluna identificando comite adm, fisc, dir
# "COMITÊ DE AUDITORIA"       "CONSELHO DE ADMINISTRACAO"
# "CONSELHO FISCAL"           "DIRETORIA EXECUTIVA"

estrutura_governanca <- estrutura_governanca |>
   dplyr::mutate(orgao = dplyr::case_when(
      stringr::str_detect(orgao, "EXECUTIV") |
         stringr::str_detect(orgao, "DIRETOR") ~ "DIRETORIA EXECUTIVA",
      stringr::str_detect(orgao, "ADMIN") ~ "CONSELHO DE ADMINISTRAÇÃO",
      TRUE ~ orgao
   ))

estrutura_governanca |> dplyr::count(orgao)

write.csv(estrutura_governanca, glue::glue("{caminho}/{datacoleta}_CoopCred_BCB_estrutura_governanca.csv"), row.names = FALSE)
write.csv(numero_de_agencias_coop, glue::glue("{caminho}/{datacoleta}_CoopCred_BCB_numero_de_agencias.csv"), row.names = FALSE)

if(nrow(auditor_independente_coop) !=0) {
   write.csv(auditor_independente_coop, glue::glue("{caminho}/{datacoleta}_CoopCred_BCB_auditorIndependente.csv"), row.names = FALSE)
} else {
   cat("Arquivo vazio")
}


# Baixando Rede de Atendimento --------------------------------------------

# As informaçóes da Rede de Atendimento estão em outro link.
# Não encontrei um caminho para pegar o Json igual os itens anteriores,
# apenas pelo link abaixo, que precisa de um id do bacen.

# Exemplo
# httr::GET(
#    "https://www3.bcb.gov.br/informes/rest/agencia/csv?pso=Z9984384",
#    httr::write_disk("teste.csv", overwrite = TRUE)
# )

# Pegando idBacen
idbacen  <- data.frame()

for (i in 1:length(cnpj)) {
   dcoop <-
      jsonlite::fromJSON(
         paste0(
            "https://www3.bcb.gov.br/informes/rest/pessoasJuridicas?cnpj=",
            cnpj[i],
            ""
         )
      )
   
   print(paste0("CNPJ ", cnpj[i], " - pegando código bacen -", i, " em ", length(cnpj), ""))
   
   idbacen_i <- dcoop %>% purrr::pluck(., "cnpj") %>%
      as.data.frame() %>%
      data.table::setnames(".", "cnpj") %>%
      dplyr::mutate(idbacen = purrr::pluck(dcoop, "idBacen", .default = NA)) %>%
      dplyr::select(cnpj, idbacen)
   
   if (exists("idbacen_i")) {
      if (nrow(idbacen) == 0) {
         idbacen <- idbacen_i
      } else {
         idbacen <- idbacen %>% rbind(idbacen_i)
         rm(idbacen_i)
      }
   } else {
      print("Faz nada")
   }
   
}

# Baixando todos os .csv

rede_atendimento <- data.frame()

for (i in 1:length(cnpj)) {
   
   print(paste0("CNPJ ", cnpj[i], " - pegando rede_atendimento - ", i, " em ", length(cnpj), ""))
   
   httr::GET(
      "https://www3.bcb.gov.br/informes/rest/agencia/csv?pso=Z9984384",
      httr::write_disk(glue::glue("{caminho}/apagar{cnpj[i]}.csv"), overwrite = TRUE)
   )
   
   rede_atendimento_i <- read.csv(glue::glue("{caminho}/apagar{cnpj[i]}.csv"), sep = ";", skip = 16)
   
   rede_atendimento_i <- rede_atendimento_i |> dplyr::mutate(cnpj = glue::glue("{cnpj[i]}")) |> dplyr::select(cnpj, everything()) |> dplyr::slice(1:(dplyr::n() - 1)) |>  janitor::clean_names()
   
   if (exists("rede_atendimento_i")){
      if (nrow(rede_atendimento)==0){
         rede_atendimento <- rede_atendimento_i
      } else {
         rede_atendimento <- rede_atendimento %>% rbind(rede_atendimento_i)
         rm(rede_atendimento_i)
      }
   } else {
      print("Faz nada")
   }

   file.remove(file.path(glue::glue("{caminho}/apagar{cnpj[i]}.csv")))
   
} 


write.csv(rede_atendimento, glue::glue("{caminho}/{datacoleta}_CoopCred_BCB_rede_atendimento.csv"), row.names = FALSE)


# Escrevendo dados atualizados no READ.me ---------------------------------
paste0(
"# Webscrapping dos Orgãos Estatutários das Cooperativas de Crédito - BACEN

Script criado para baixar informações sobre os órgãos estatutários das Cooperativas de Crédito disponíveis no site do Banco Central do Brasil (BACEN).

As informações serão coletadas do endereço: [https://www.bcb.gov.br/estabilidadefinanceira/encontreinstituicao](https://www.bcb.gov.br/estabilidadefinanceira/encontreinstituicao)

Ele irá criar uma pasta dentro de `dados` com o nome de `anomes` e irá gravar os arquivos nela.  

Ele irá baixar as infomações: 

   info_gerais_coop:
   
      nome
      
      naturezaJuridica
      
      situacao
      
      regimeEspecial
      
      endereco
      
      telefone
      
      segmentoPrudencial
      
      atoPresi
      
      nomeLiquidante
      
      filiacao
      
      filiacaoCooperativaCentral

   
   comite_auditoria_coop:
   
      orgaos
      
      administradores
      
   estrutura_governanca:
   
      orgaos
      
      administradores
   
   auditor_independente:
   
      nome do auditor independente
      
   numero_de_agencias_coop:
   
         numero agencias
   
   rede_atendimento:

         endereco
         


Atualizado em: ", format(Sys.Date(), '%d %b %Y'), ".
<hr> \n
## Cooperativas de Crédito: \n
### Tabela de informações gerais: \n", paste(info_gerais_coop |> head(5) |>  knitr::kable(), collapse = "\n"), 
"\n

### Tabela de comitê de auditoria: \n", paste(comite_auditoria_coop |> head(5) |> knitr::kable(), collapse = "\n"), 
"\n

### Tabela de estrutura de governança: \n", paste(estrutura_governanca |> head(5) |> knitr::kable(), collapse = "\n"), 
"\n

### Tabela de auditor independente: \n", paste(auditor_independente_coop |> head(5) |> knitr::kable(), collapse = "\n"), 
"\n

### Tabela de número de agências: \n", paste(numero_de_agencias_coop |> head(5) |> knitr::kable(), collapse = "\n"), 
"\n

### Tabela de rede de atendimento: \n", paste(rede_atendimento |> head(5) |>  dplyr::mutate_all(~ iconv(., from = "UTF-8", to = "UTF-8//IGNORE")) |>  knitr::kable(), collapse = "\n"), 
"\n") |> writeLines("README.md")







