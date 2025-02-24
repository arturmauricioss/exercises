import Foundation
import SQLite

// Conexão com o banco de dados
let db: Connection

do {
    db = try Connection("banco.db")
} catch {
    print("Não foi possível conectar ao banco de dados: \(error)")
    exit(1)
}

// Definindo a tabela de produtos
let produtos = Table("produtos")
let id = Expression<Int>("id")
let nome = Expression<String>("nome")
let preco = Expression<Double>("preco")

// Criar tabela se não existir
func criarTabela() {
    do {
        try db.run(produtos.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(nome)
            t.column(preco)
        })
    } catch {
        print("Erro ao criar a tabela: \(error)")
    }
}

// Criar um novo produto
func criarProduto() {
    print("Nome do produto: ", terminator: "")
    let nomeProduto = readLine() ?? ""
    
    print("Preço do produto: ", terminator: "")
    let precoProduto = Double(readLine() ?? "") ?? 0.0
    
    let insert = produtos.insert(nome <- nomeProduto, preco <- precoProduto)
    do {
        try db.run(insert)
        print("✅ Produto cadastrado com sucesso!")
    } catch {
        print("Erro ao cadastrar o produto: \(error)")
    }
}

// Listar todos os produtos
func listarProdutos() {
    do {
        let produtosList = try db.prepare(produtos)
        if productosList.isEmpty {
            print("📭 Nenhum produto encontrado.")
        } else {
            print("\n📜 Lista de Produtos:")
            for produto in produtosList {
                print("\(produto[id]) - \(produto[nome]) - R$ \(produto[preco])")
            }
        }
    } catch {
        print("Erro ao listar produtos: \(error)")
    }
}

// Atualizar um produto existente
func atualizarProduto() {
    listarProdutos()
    
    print("\nDigite o ID do produto que deseja atualizar: ", terminator: "")
    guard let idProduto = Int(readLine() ?? ""), let produto = try? db.pluck(produtos.filter(id == idProduto)) else {
        print("Produto não encontrado.")
        return
    }
    
    print("Novo nome: ", terminator: "")
    let novoNome = readLine() ?? ""
    
    print("Novo preço: ", terminator: "")
    let novoPreco = Double(readLine() ?? "") ?? produto[preco]
    
    let update = produtos.filter(id == idProduto).update(nome <- novoNome, preco <- novoPreco)
    do {
        if try db.run(update) > 0 {
            print("🔄 Produto atualizado com sucesso!")
        } else {
            print("Produto não encontrado.")
        }
    } catch {
        print("Erro ao atualizar o produto: \(error)")
    }
}

// Deletar um produto
func deletarProduto() {
    listarProdutos()
    
    print("\nDigite o ID do produto que deseja deletar: ", terminator: "")
    guard let idProduto = Int(readLine() ?? "") else {
        print("ID inválido.")
        return
    }
    
    let produtoParaDeletar = produtos.filter(id == idProduto)
    do {
        if try db.run(produtoParaDeletar.delete()) > 0 {
            print("🗑️ Produto deletado com sucesso!")
        } else {
            print("Produto não encontrado.")
        }
    } catch {
        print("Erro ao deletar o produto: \(error)")
    }
}

// Menu interativo
func menu() {
    criarTabela() // Garantir que a tabela existe
    while true {
        print("\n📌 MENU CRUD - SQLite")
        print("1. Criar Produto")
        print("2. Listar Produtos")
        print("3. Atualizar Produto")
        print("4. Deletar Produto")
        print("5. Sair")
        
        print("Escolha uma opção: ", terminator: "")
        let opcao = readLine()
        
        switch opcao {
        case "1":
            criarProduto()
        case "2":
            listarProdutos()
        case "3":
            atualizarProduto()
        case "4":
            deletarProduto()
        case "5":
            print("🚪 Saindo...")
            exit(0)
        default:
            print("⚠️ Opção inválida! Tente novamente.")
        }
    }
}

// Executar o menu
menu()
