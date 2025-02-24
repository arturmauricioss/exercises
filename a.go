package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/mattn/go-sqlite3"
)

// Função para conectar ao banco de dados
func conectar() *sql.DB {
	db, err := sql.Open("sqlite3", "banco.db")
	if err != nil {
		log.Fatal(err)
	}
	return db
}

// Criar tabela se não existir
func criarTabela(db *sql.DB) {
	query := `
	CREATE TABLE IF NOT EXISTS produtos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nome TEXT NOT NULL,
		preco REAL NOT NULL
	);`
	_, err := db.Exec(query)
	if err != nil {
		log.Fatal(err)
	}
}

// Criar um novo produto
func criarProduto(db *sql.DB) {
	var nome string
	var preco float64

	fmt.Print("Nome do produto: ")
	fmt.Scan(&nome)

	fmt.Print("Preço do produto: ")
	fmt.Scan(&preco)

	query := "INSERT INTO produtos (nome, preco) VALUES (?, ?)"
	_, err := db.Exec(query, nome, preco)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("✅ Produto cadastrado com sucesso!")
}

// Listar todos os produtos
func listarProdutos(db *sql.DB) {
	query := "SELECT * FROM produtos"
	rows, err := db.Query(query)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	if !rows.Next() {
		fmt.Println("📭 Nenhum produto encontrado.")
		return
	}

	fmt.Println("\n📜 Lista de Produtos:")
	for {
		var id int
		var nome string
		var preco float64
		err := rows.Scan(&id, &nome, &preco)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("%d - %s - R$ %.2f\n", id, nome, preco)
		if !rows.Next() {
			break
		}
	}
}

// Atualizar um produto existente
func atualizarProduto(db *sql.DB) {
	listarProdutos(db)

	var id int
	var novoNome string
	var novoPreco float64

	fmt.Print("\nDigite o ID do produto que deseja atualizar: ")
	fmt.Scan(&id)

	fmt.Print("Novo nome: ")
	fmt.Scan(&novoNome)

	fmt.Print("Novo preço: ")
	fmt.Scan(&novoPreco)

	query := "UPDATE produtos SET nome = ?, preco = ? WHERE id = ?"
	_, err := db.Exec(query, novoNome, novoPreco, id)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("🔄 Produto atualizado com sucesso!")
}

// Deletar um produto
func deletarProduto(db *sql.DB) {
	listarProdutos(db)

	var id int
	fmt.Print("\nDigite o ID do produto que deseja deletar: ")
	fmt.Scan(&id)

	query := "DELETE FROM produtos WHERE id = ?"
	_, err := db.Exec(query, id)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("🗑️ Produto deletado com sucesso!")
}

// Menu interativo
func menu() {
	db := conectar()
	defer db.Close()
	criarTabela(db) // Garantir que a tabela existe

	for {
		fmt.Println("\n📌 MENU CRUD - SQLite")
		fmt.Println("1. Criar Produto")
		fmt.Println("2. Listar Produtos")
		fmt.Println("3. Atualizar Produto")
		fmt.Println("4. Deletar Produto")
		fmt.Println("5. Sair")

		var opcao int
		fmt.Print("Escolha uma opção: ")
		fmt.Scan(&opcao)

		switch opcao {
		case 1:
			criarProduto(db)
		case 2:
			listarProdutos(db)
		case 3:
			atualizarProduto(db)
		case 4:
			deletarProduto(db)
		case 5:
			fmt.Println("🚪 Saindo...")
			os.Exit(0)
		default:
			fmt.Println("⚠️ Opção inválida! Tente novamente.")
		}
	}
}

// Função principal
func main() {
	menu()
}
