local sqlite3 = require("lsqlite3")

-- Função para conectar ao banco de dados
local function conectar()
    local db = sqlite3.open("banco.db")
    return db
end

-- Criar a tabela se não existir
local function criar_tabela()
    local db = conectar()
    db:exec([[
        CREATE TABLE IF NOT EXISTS produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
        )
    ]])
    db:close()
end

-- Criar um novo produto
local function criar_produto()
    io.write("Nome do produto: ")
    local nome = io.read()
    io.write("Preço do produto: ")
    local preco = tonumber(io.read())
    
    local db = conectar()
    db:exec("INSERT INTO produtos (nome, preco) VALUES (?, ?)", nome, preco)
    db:close()
    print("✅ Produto cadastrado com sucesso!")
end

-- Listar todos os produtos
local function listar_produtos()
    local db = conectar()
    for row in db:nrows("SELECT * FROM produtos") do
        print(string.format("%d - %s - R$ %.2f", row.id, row.nome, row.preco))
    end
    db:close()
end

-- Atualizar um produto existente
local function atualizar_produto()
    listar_produtos()
    io.write("\nDigite o ID do produto que deseja atualizar: ")
    local id_produto = tonumber(io.read())
    io.write("Novo nome: ")
    local novo_nome = io.read()
    io.write("Novo preço: ")
    local novo_preco = tonumber(io.read())

    local db = conectar()
    db:exec(string.format("UPDATE produtos SET nome = '%s', preco = %f WHERE id = %d", novo_nome, novo_preco, id_produto))
    db:close()
    print("🔄 Produto atualizado com sucesso!")
end

-- Deletar um produto
local function deletar_produto()
    listar_produtos()
    io.write("\nDigite o ID do produto que deseja deletar: ")
    local id_produto = tonumber(io.read())

    local db = conectar()
    db:exec(string.format("DELETE FROM produtos WHERE id = %d", id_produto))
    db:close()
    print("🗑️ Produto deletado com sucesso!")
end

-- Menu interativo
local function menu()
    criar_tabela()  -- Garantir que a tabela existe
    while true do
        print("\n📌 MENU CRUD - SQLite")
        print("1. Criar Produto")
        print("2. Listar Produtos")
        print("3. Atualizar Produto")
        print("4. Deletar Produto")
        print("5. Sair")

        io.write("Escolha uma opção: ")
        local opcao = io.read()

        if opcao == "1" then
            criar_produto()
        elseif opcao == "2" then
            listar_produtos()
        elseif opcao == "3" then
            atualizar_produto()
        elseif opcao == "4" then
            deletar_produto()
        elseif opcao == "5" then
            print("🚪 Saindo...")
            break
        else
            print("⚠️ Opção inválida! Tente novamente.")
        end
    end
end

-- Executar o menu
menu()
