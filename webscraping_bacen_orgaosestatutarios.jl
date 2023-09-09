# Importar módulos úteis
using HTTP
using Dates
using CSV
using DataFrames
using JSON
import Base
using DataStructures 

# Data da coleta
datacoleta = Dates.format(now(), "yyyymm")

# Local para salvar os arquivos
caminho = "dados/$(datacoleta)"

# Criando pasta destino
if isdir(caminho)
    println("A pasta já existe")
else
    mkdir(caminho)
    println("Pasta criada.")
end

dest_file = "$caminho/$(datacoleta)_cnpj_coopcred.csv"

u_bc_csv = "https://www3.bcb.gov.br/informes/rest/pessoasJuridicas/csv?seg=9&age=true"

response = HTTP.get(u_bc_csv)
open(dest_file, "w") do file
    write(file, response.body)
end

# Tratando csv baixado
# Ler o CSV usando o pacote CSV
cnpj_coopcred = CSV.File(dest_file, delim=';', header=8) |> DataFrame

# Limpar os nomes das colunas
rename!(cnpj_coopcred, Symbol("CNPJ") => :cnpj)

# Filtrar as cooperativas de crédito sem CNPJ
cnpj_coopcred = filter(row -> !ismissing(row.cnpj), cnpj_coopcred)


# Baixando informações estatutarias -------------------------

# Definindo vetor de cnpj que será buscado
cnpj = cnpj_coopcred[!, :cnpj]

# Carrega df Vazios
cs = ["cnpj", "naturezaJuridica", "situacao", "regimeEspecial", "logradouro", "complemento", "bairro", "municipio", "siglaEstado", "cep", "email", "segmentoPrudencial", "filiacao", "tel_ouvidoria", "nome_ouvidor"]
info_gerais_coop = DataFrame()

for i in 1:length(cnpj)
    
    println("CNPJ ", cnpj[i], " --- ", i, " de ", length(cnpj))
    
    url = "https://www3.bcb.gov.br/informes/rest/pessoasJuridicas?cnpj=$(cnpj[i])"
    response = HTTP.get(url)
    dcoop = JSON.parse(String(response.body))

    println("CNPJ ", cnpj[i], " Info. Gerais")

    dcoops = merge(dcoop, dcoop["endereco"], dcoop["endereco"]["municipio"])
    new = DataFrame(filter(((k,v),) -> k in cs, dcoops))
    new[!, :nome_coop] = [dcoop["nome"]]
    new[!, :municipio] = [dcoop["endereco"]["municipio"]["nome"]]
    new[!, :classe] = [!isnothing(dcoop["classeCooperativa"]) ? dcoop["classeCooperativa"]["nome"] : nothing]
    new[!, :filiacao] = [!isnothing(dcoop["filiacao"]) ? dcoop["filiacao"] : nothing]
    new[!, :tel_ouvidoria] = [!isnothing(dcoop["ouvidoria"]) ? dcoop["ouvidoria"]["telefone"] : nothing]
    new[!, :nome_ouvidoria] = [!isnothing(dcoop["ouvidoria"]) ? dcoop["ouvidoria"]["nomeOuvidor"] : nothing]
    info_gerais_coop = [info_gerais_coop;new]
        

end

# Organizar as colunas na ordem desejada
info_gerais_coop = info_gerais_coop[:, Cols(:cnpj, :nome_coop, :classe, :)]


CSV.write("dados/$(datacoleta)/info_gerais.csv", info_gerais_coop; transform = (col, val) -> isnothing(val) ? missing : val)