# Webscrapping dos Orgãos Estatutários das Cooperativas de Crédito - BACEN

Objetivo deste script é fazer o download das informações, mas utilizando a linguagem `Julia`.

Este script é a tradução de um script em `R`, que pode ser encontrado em [aqui](https://github.com/rtheodoro/orgaos-estatutarios-coop-cred-bacen)

*PROBLEMAS*: ainda não consegui extrair dados quando uma das cooperativas não possui a informação, como por exemplo: classe, filiacao, telefone e ouvidoria. Se uma cooperativa não possui classe, o script não consegue extrair as informações das demais cooperativas.


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
