# Importar módulos úteis
using HTTP
using Dates
using CSV
using DataFrames
using JSON
import Base


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

# Visualizar as primeiras linhas do DataFrame
first(cnpj_coopcred, 5)


# Baixando informações estatutarias
cnpj = cnpj_coopcred[!, :cnpj]

# Carrega df Vazios
info_gerais_coop = DataFrame()

for i in 1:length(cnpj)

    println("CNPJ ", cnpj[i], " --- ", i, " de ", length(cnpj))

    # Fetch JSON data
    url = "https://www3.bcb.gov.br/informes/rest/pessoasJuridicas?cnpj=$(cnpj[i])"
    response = HTTP.get(url)
    dcoop = JSON.parse(String(response.body))

    println("CNPJ ", cnpj[i], " Info. Gerais")

    # Extracting information
    info_gerais_coop_i = DataFrame(
    cnpj_coop = cnpj[i],
    nome_coop = dcoop["nome"],
    naturezaJuridica = String(get(dcoop, "naturezaJuridica", missing)),
    #classe = get(get(get(dcoop, "classeCooperativa", nothing), "nome", nothing), 1),
    situacao = String(get(dcoop, "situacao", missing)),
    regimeEspecial = dcoop["regimeEspecial"],
    logradouro = String(get(get(dcoop, "endereco", missing), "logradouro", missing)),
    complemento = String(get(get(dcoop, "endereco", missing), "complemento", missing)),
    bairro = String(get(get(dcoop, "endereco", missing), "bairro", missing)),
    municipio = String(get(get(get(dcoop, "endereco", missing), "municipio", missing), "nome", missing)),
    uf = String(get(get(get(dcoop, "endereco", missing), "municipio", missing), "siglaEstado", missing)),
    cep = String(get(get(dcoop, "endereco", missing), "cep", missing)),
    endereco_eletronico = String(get(get(dcoop, "endereco", missing), "email", missing)),
    email = String(get(get(dcoop, "endereco", missing), "email", missing)),
    segmento_prudencial = get(dcoop, "segmentoPrudencial", missing),
    #filiacao = get(dcoop, "filiacoesCooperativaCentral", missing)
)

    # Check if info_gerais_coop_i exists and merge

    if isempty(info_gerais_coop)
        info_gerais_coop = copy(info_gerais_coop_i)
    else
        info_gerais_coop = vcat(info_gerais_coop, info_gerais_coop_i)
        info_gerais_coop_i = nothing
    end
        

end

CSV.write("dados/$(datacoleta)/info_gerais.csv", info_gerais_coop; transform = (col, val) -> isnothing(val) ? missing : val)