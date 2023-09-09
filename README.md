# Webscrapping dos Orgãos Estatutários das Cooperativas de Crédito - BACEN

Objetivo deste script foi aprender `Julia` fazendo download das informações das Cooperativas de Crédito do Bacen.

Este script é a tradução de um script em `R`, que pode ser encontrado em [aqui](https://github.com/rtheodoro/orgaos-estatutarios-coop-cred-bacen)

***PROBLEMAS***: ainda não consegui extrair dados quando uma das cooperativas não possui a informação, como por exemplo: **classe, filiacao, telefone e ouvidoria**. Se uma cooperativa não possui classe, o script não consegue extrair as informações das demais cooperativas.


As informações serão coletadas do endereço: [https://www.bcb.gov.br/estabilidadefinanceira/encontreinstituicao](https://www.bcb.gov.br/estabilidadefinanceira/encontreinstituicao)

Ele irá criar uma pasta dentro de `dados` com o nome de `anomes` e irá gravar os arquivos nela.  

Ele irá baixar as infomações: 

   info_gerais_coop:
   
      nome
      
      naturezaJuridica
      
      situacao
      
      segmentoPrudencial
      
      endereco

      

