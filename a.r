# Carregar o pacote RSQLite
library(RSQLite)

# Função para conectar ao banco de dados
conectar <- function() {
  dbConnect(SQLite(), dbname = "banco.db")
}

# Criar a tabela se não existir
criar_tabela <- function() {
  conn <- conectar()
  dbExecute(conn, "
    CREATE TABLE IF NOT EXISTS produtos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      preco REAL NOT NULL
    )
  ")
  dbDisconnect(conn)
}

# Criar um novo produto
criar_produto <- function() {
  nome <- readline("Nome do produto: ")
  preco <- as.numeric(readline("Preço do produto: "))
  
  conn <- conectar()
  dbExecute(conn, "INSERT INTO produtos (nome, preco) VALUES (?, ?)", params = list(nome, preco))
  dbDisconnect(conn)
  cat("✅ Produto cadastrado com sucesso!\n")
}

# Listar todos os produtos
listar_produtos <- function() {
  conn <- conectar()
  produtos <- dbGetQuery(conn, "SELECT * FROM produtos")
  dbDisconnect(conn)

  if (nrow(produtos) == 0) {
    cat("📭 Nenhum produto encontrado.\n")
  } else {
    cat("\n📜 Lista de Produtos:\n")
    print(produtos)
  }
}

# Atualizar um produto existente
atualizar_produto <- function() {
  listar_produtos()
  id_produto <- as.integer(readline("\nDigite o ID do produto que deseja atualizar: "))
  novo_nome <- readline("Novo nome: ")
  novo_preco <- as.numeric(readline("Novo preço: "))

  conn <- conectar()
  dbExecute(conn, "UPDATE produtos SET nome = ?, preco = ? WHERE id = ?", params = list(novo_nome, novo_preco, id_produto))
  dbDisconnect(conn)
  cat("🔄 Produto atualizado com sucesso!\n")
}

# Deletar um produto
deletar_produto <- function() {
  listar_produtos()
  id_produto <- as.integer(readline("\nDigite o ID do produto que deseja deletar: "))

  conn <- conectar()
  dbExecute(conn, "DELETE FROM produtos WHERE id = ?", params = list(id_produto))
  dbDisconnect(conn)
  cat("🗑️ Produto deletado com sucesso!\n")
}

# Menu interativo
menu <- function() {
  criar_tabela()  # Garantir que a tabela existe
  repeat {
    cat("\n📌 MENU CRUD - SQLite\n")
    cat("1. Criar Produto\n")
    cat("2. Listar Produtos\n")
    cat("3. Atualizar Produto\n")
    cat("4. Deletar Produto\n")
    cat("5. Sair\n")

    opcao <- readline("Escolha uma opção: ")

    if (opcao == "1") {
      criar_produto()
    } else if (opcao == "2") {
      listar_produtos()
    } else if (opcao == "3") {
      atualizar_produto()
    } else if (opcao == "4") {
      deletar_produto()
    } else if (opcao == "5") {
      cat("🚪 Saindo...\n")
      break
    } else {
      cat("⚠️ Opção inválida! Tente novamente.\n")
    }
  }
}

# Executar o menu
menu()
