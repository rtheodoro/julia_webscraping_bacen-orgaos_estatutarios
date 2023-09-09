# Webscrapping dos Orgãos Estatutários das Cooperativas de Crédito - BACEN

Objetivo deste script é fazer o download das informações, mas utilizando a linguagem `Julia`.

Este script é a tradução de um script em `R`, que pode ser encontrado em [aqui](https://github.com/rtheodoro/orgaos-estatutarios-coop-cred-bacen).

Aqui será possível observar um exemplo de como pegar uma página de um site em `JSON`, baixar e coletar os dados.

## Como funciona

As informações serão coletadas do endereço: [https://www.bcb.gov.br/estabilidadefinanceira/encontreinstituicao](https://www.bcb.gov.br/estabilidadefinanceira/encontreinstituicao)

Será criado uma pasta dentro de `dados` com o nome de `anomes` e irá gravar os arquivos nela.  

Então serão baixadas as infomações: 

   info_gerais_coop:
   
      nome

      classe
      
      naturezaJuridica
      
      situacao
      
      regimeEspecial
      
      endereco
      
      telefone
      
      segmentoPrudencial
      
      atoPresi
      
      nomeLiquidante
      
      filiacao
      
      ouvidoria

   
