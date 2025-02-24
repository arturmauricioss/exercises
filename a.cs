using System;
using System.Data.SQLite;

class Program
{
    private const string ConnectionString = "Data Source=banco.db;Version=3;";

    static void Main(string[] args)
    {
        CriarTabela();

        while (true)
        {
            Console.WriteLine("\n📌 MENU CRUD - SQLite");
            Console.WriteLine("1. Criar Produto");
            Console.WriteLine("2. Listar Produtos");
            Console.WriteLine("3. Atualizar Produto");
            Console.WriteLine("4. Deletar Produto");
            Console.WriteLine("5. Sair");

            Console.Write("Escolha uma opção: ");
            string opcao = Console.ReadLine();

            switch (opcao)
            {
                case "1":
                    CriarProduto();
                    break;
                case "2":
                    ListarProdutos();
                    break;
                case "3":
                    AtualizarProduto();
                    break;
                case "4":
                    DeletarProduto();
                    break;
                case "5":
                    Console.WriteLine("🚪 Saindo...");
                    return;
                default:
                    Console.WriteLine("⚠️ Opção inválida! Tente novamente.");
                    break;
            }
        }
    }

    static void CriarTabela()
    {
        using (var connection = new SQLiteConnection(ConnectionString))
        {
            connection.Open();
            string sql = @"
                CREATE TABLE IF NOT EXISTS produtos (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    nome TEXT NOT NULL,
                    preco REAL NOT NULL
                )";
            using (var command = new SQLiteCommand(sql, connection))
            {
                command.ExecuteNonQuery();
            }
        }
    }

    static void CriarProduto()
    {
        Console.Write("Nome do produto: ");
        string nome = Console.ReadLine();
        Console.Write("Preço do produto: ");
        double preco = Convert.ToDouble(Console.ReadLine());

        using (var connection = new SQLiteConnection(ConnectionString))
        {
            connection.Open();
            string sql = "INSERT INTO produtos (nome, preco) VALUES (@nome, @preco)";
            using (var command = new SQLiteCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@nome", nome);
                command.Parameters.AddWithValue("@preco", preco);
                command.ExecuteNonQuery();
            }
        }
        Console.WriteLine("✅ Produto cadastrado com sucesso!");
    }

    static void ListarProdutos()
    {
        using (var connection = new SQLiteConnection(ConnectionString))
        {
            connection.Open();
            string sql = "SELECT * FROM produtos";
            using (var command = new SQLiteCommand(sql, connection))
            {
                using (var reader = command.ExecuteReader())
                {
                    if (!reader.HasRows)
                    {
                        Console.WriteLine("📭 Nenhum produto encontrado.");
                        return;
                    }

                    Console.WriteLine("\n📜 Lista de Produtos:");
                    while (reader.Read())
                    {
                        Console.WriteLine($"{reader["id"]} - {reader["nome"]} - R$ {reader["preco"]}");
                    }
                }
            }
        }
    }

    static void AtualizarProduto()
    {
        ListarProdutos();
        Console.Write("\nDigite o ID do produto que deseja atualizar: ");
        int id = Convert.ToInt32(Console.ReadLine());
        Console.Write("Novo nome: ");
        string novoNome = Console.ReadLine();
        Console.Write("Novo preço: ");
        double novoPreco = Convert.ToDouble(Console.ReadLine());

        using (var connection = new SQLiteConnection(ConnectionString))
        {
            connection.Open();
            string sql = "UPDATE produtos SET nome = @nome, preco = @preco WHERE id = @id";
            using (var command = new SQLiteCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@nome", novoNome);
                command.Parameters.AddWithValue("@preco", novoPreco);
                command.Parameters.AddWithValue("@id", id);
                command.ExecuteNonQuery();
            }
        }
        Console.WriteLine("🔄 Produto atualizado com sucesso!");
    }

    static void DeletarProduto()
    {
        ListarProdutos();
        Console.Write("\nDigite o ID do produto que deseja deletar: ");
        int id = Convert.ToInt32(Console.ReadLine());

        using (var connection = new SQLiteConnection(ConnectionString))
        {
            connection.Open();
            string sql = "DELETE FROM produtos WHERE id = @id";
            using (var command = new SQLiteCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@id", id);
                command.ExecuteNonQuery();
            }
        }
        Console.WriteLine("🗑️ Produto deletado com sucesso!");
    }
}
