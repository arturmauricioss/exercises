import java.sql.{Connection, DriverManager, ResultSet}
import scala.io.StdIn.readLine

object CrudSQLite {
  val url = "jdbc:sqlite:banco.db"

  // Conectar ao banco de dados
  def conectar(): Connection = DriverManager.getConnection(url)

  // Criar tabela se não existir
  def criarTabela(): Unit = {
    val conn = conectar()
    val stmt = conn.createStatement()
    stmt.executeUpdate("""
      CREATE TABLE IF NOT EXISTS produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        preco REAL NOT NULL
      )
    """)
    stmt.close()
    conn.close()
  }

  // Criar um novo produto
  def criarProduto(): Unit = {
    print("Nome do produto: ")
    val nome = readLine()
    print("Preço do produto: ")
    val preco = readLine().toDouble
    
    val conn = conectar()
    val stmt = conn.prepareStatement("INSERT INTO produtos (nome, preco) VALUES (?, ?)")
    stmt.setString(1, nome)
    stmt.setDouble(2, preco)
    stmt.executeUpdate()
    stmt.close()
    conn.close()
    println("✅ Produto cadastrado com sucesso!")
  }

  // Listar todos os produtos
  def listarProdutos(): Unit = {
    val conn = conectar()
    val stmt = conn.createStatement()
    val rs = stmt.executeQuery("SELECT * FROM produtos")
    
    println("\n📜 Lista de Produtos:")
    while (rs.next()) {
      println(s"${rs.getInt("id")} - ${rs.getString("nome")} - R$ ${rs.getDouble("preco")}")
    }
    stmt.close()
    conn.close()
  }

  // Atualizar um produto
  def atualizarProduto(): Unit = {
    listarProdutos()
    print("\nDigite o ID do produto que deseja atualizar: ")
    val id = readLine().toInt
    print("Novo nome: ")
    val novoNome = readLine()
    print("Novo preço: ")
    val novoPreco = readLine().toDouble
    
    val conn = conectar()
    val stmt = conn.prepareStatement("UPDATE produtos SET nome = ?, preco = ? WHERE id = ?")
    stmt.setString(1, novoNome)
    stmt.setDouble(2, novoPreco)
    stmt.setInt(3, id)
    stmt.executeUpdate()
    stmt.close()
    conn.close()
    println("🔄 Produto atualizado com sucesso!")
  }

  // Deletar um produto
  def deletarProduto(): Unit = {
    listarProdutos()
    print("\nDigite o ID do produto que deseja deletar: ")
    val id = readLine().toInt
    
    val conn = conectar()
    val stmt = conn.prepareStatement("DELETE FROM produtos WHERE id = ?")
    stmt.setInt(1, id)
    stmt.executeUpdate()
    stmt.close()
    conn.close()
    println("🗑️ Produto deletado com sucesso!")
  }

  // Menu interativo
  def menu(): Unit = {
    criarTabela()
    var continuar = true
    while (continuar) {
      println("\n📌 MENU CRUD - SQLite")
      println("1. Criar Produto")
      println("2. Listar Produtos")
      println("3. Atualizar Produto")
      println("4. Deletar Produto")
      println("5. Sair")
      print("Escolha uma opção: ")
      
      readLine() match {
        case "1" => criarProduto()
        case "2" => listarProdutos()
        case "3" => atualizarProduto()
        case "4" => deletarProduto()
        case "5" =>
          println("🚪 Saindo...")
          continuar = false
        case _ => println("⚠️ Opção inválida! Tente novamente.")
      }
    }
  }

  def main(args: Array[String]): Unit = {
    menu()
  }
}
