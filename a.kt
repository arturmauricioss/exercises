import java.sql.Connection
import java.sql.DriverManager
import java.sql.ResultSet
import java.sql.Statement
import java.util.Scanner

// Função para conectar ao banco de dados
fun conectar(): Connection {
    return DriverManager.getConnection("jdbc:sqlite:banco.db")
}

// Criar tabela se não existir
fun criarTabela() {
    val conn = conectar()
    val statement: Statement = conn.createStatement()
    statement.executeUpdate("""
        CREATE TABLE IF NOT EXISTS produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
        )
    """)
    conn.close()
}

// Criar um novo produto
fun criarProduto() {
    val scanner = Scanner(System.`in`)
    print("Nome do produto: ")
    val nome = scanner.nextLine()
    
    print("Preço do produto: ")
    val preco = scanner.nextDouble()

    val conn = conectar()
    val statement: Statement = conn.createStatement()
    statement.executeUpdate("INSERT INTO produtos (nome, preco) VALUES ('$nome', $preco)")
    conn.close()
    println("✅ Produto cadastrado com sucesso!")
}

// Listar todos os produtos
fun listarProdutos() {
    val conn = conectar()
    val statement: Statement = conn.createStatement()
    val resultSet: ResultSet = statement.executeQuery("SELECT * FROM produtos")

    if (!resultSet.next()) {
        println("📭 Nenhum produto encontrado.")
    } else {
        println("\n📜 Lista de Produtos:")
        do {
            println("${resultSet.getInt("id")} - ${resultSet.getString("nome")} - R$ ${resultSet.getDouble("preco")}")
        } while (resultSet.next())
    }
    conn.close()
}

// Atualizar um produto existente
fun atualizarProduto() {
    listarProdutos()
    val scanner = Scanner(System.`in`)
    print("\nDigite o ID do produto que deseja atualizar: ")
    val idProduto = scanner.nextInt()
    scanner.nextLine()  // Limpar o buffer

    print("Novo nome: ")
    val novoNome = scanner.nextLine()

    print("Novo preço: ")
    val novoPreco = scanner.nextDouble()

    val conn = conectar()
    val statement: Statement = conn.createStatement()
    statement.executeUpdate("UPDATE produtos SET nome = '$novoNome', preco = $novoPreco WHERE id = $idProduto")
    conn.close()
    println("🔄 Produto atualizado com sucesso!")
}

// Deletar um produto
fun deletarProduto() {
    listarProdutos()
    val scanner = Scanner(System.`in`)
    print("\nDigite o ID do produto que deseja deletar: ")
    val idProduto = scanner.nextInt()

    val conn = conectar()
    val statement: Statement = conn.createStatement()
    statement.executeUpdate("DELETE FROM produtos WHERE id = $idProduto")
    conn.close()
    println("🗑️ Produto deletado com sucesso!")
}

// Menu interativo
fun menu() {
    criarTabela()  // Garantir que a tabela existe
    val scanner = Scanner(System.`in`)
    while (true) {
        println("\n📌 MENU CRUD - SQLite")
        println("1. Criar Produto")
        println("2. Listar Produtos")
        println("3. Atualizar Produto")
        println("4. Deletar Produto")
        println("5. Sair")

        print("Escolha uma opção: ")
        val opcao = scanner.nextLine()

        when (opcao) {
            "1" -> criarProduto()
            "2" -> listarProdutos()
            "3" -> atualizarProduto()
            "4" -> deletarProduto()
            "5" -> {
                println("🚪 Saindo...")
                break
            }
            else -> println("⚠️ Opção inválida! Tente novamente.")
        }
    }
}

// Executar o menu
fun main() {
    menu()
}
