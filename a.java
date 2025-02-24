import java.sql.*;
import java.util.Scanner;

public class Main {
    // Função para conectar ao banco de dados
    private static Connection conectar() {
        try {
            return DriverManager.getConnection("jdbc:sqlite:banco.db");
        } catch (SQLException e) {
            System.out.println(e.getMessage());
            return null;
        }
    }

    // Criar tabela se não existir
    private static void criarTabela() {
        String sql = "CREATE TABLE IF NOT EXISTS produtos ("
                + " id INTEGER PRIMARY KEY AUTOINCREMENT,"
                + " nome TEXT NOT NULL,"
                + " preco REAL NOT NULL"
                + ");";
        try (Connection conn = conectar();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    // Criar um novo produto
    private static void criarProduto() {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Nome do produto: ");
        String nome = scanner.nextLine();

        System.out.print("Preço do produto: ");
        double preco = scanner.nextDouble();

        String sql = "INSERT INTO produtos (nome, preco) VALUES (?, ?)";
        try (Connection conn = conectar();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nome);
            pstmt.setDouble(2, preco);
            pstmt.executeUpdate();
            System.out.println("✅ Produto cadastrado com sucesso!");
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    // Listar todos os produtos
    private static void listarProdutos() {
        String sql = "SELECT * FROM produtos";
        try (Connection conn = conectar();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (!rs.next()) {
                System.out.println("📭 Nenhum produto encontrado.");
                return;
            }

            System.out.println("\n📜 Lista de Produtos:");
            do {
                int id = rs.getInt("id");
                String nome = rs.getString("nome");
                double preco = rs.getDouble("preco");
                System.out.printf("%d - %s - R$ %.2f\n", id, nome, preco);
            } while (rs.next());
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    // Atualizar um produto existente
    private static void atualizarProduto() {
        listarProdutos();
        Scanner scanner = new Scanner(System.in);
        System.out.print("\nDigite o ID do produto que deseja atualizar: ");
        int idProduto = scanner.nextInt();
        scanner.nextLine(); // Limpar o buffer

        System.out.print("Novo nome: ");
        String novoNome = scanner.nextLine();

        System.out.print("Novo preço: ");
        double novoPreco = scanner.nextDouble();

        String sql = "UPDATE produtos SET nome = ?, preco = ? WHERE id = ?";
        try (Connection conn = conectar();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, novoNome);
            pstmt.setDouble(2, novoPreco);
            pstmt.setInt(3, idProduto);
            pstmt.executeUpdate();
            System.out.println("🔄 Produto atualizado com sucesso!");
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    // Deletar um produto
    private static void deletarProduto() {
        listarProdutos();
        Scanner scanner = new Scanner(System.in);
        System.out.print("\nDigite o ID do produto que deseja deletar: ");
        int idProduto = scanner.nextInt();

        String sql = "DELETE FROM produtos WHERE id = ?";
        try (Connection conn = conectar();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idProduto);
            pstmt.executeUpdate();
            System.out.println("🗑️ Produto deletado com sucesso!");
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    // Menu interativo
    private static void menu() {
        criarTabela(); // Garantir que a tabela existe
        Scanner scanner = new Scanner(System.in);
        while (true) {
            System.out.println("\n📌 MENU CRUD - SQLite");
            System.out.println("1. Criar Produto");
            System.out.println("2. Listar Produtos");
            System.out.println("3. Atualizar Produto");
            System.out.println("4. Deletar Produto");
            System.out.println("5. Sair");

            System.out.print("Escolha uma opção: ");
            String opcao = scanner.nextLine();

            switch (opcao) {
                case "1":
                    criarProduto();
                    break;
                case "2":
                    listarProdutos();
                    break;
                case "3":
                    atualizarProduto();
                    break;
                case "4":
                    deletarProduto();
                    break;
                case "5":
                    System.out.println("🚪 Saindo...");
                    return;
                default:
                    System.out.println("⚠️ Opção inválida! Tente novamente.");
            }
        }
    }

    // Função principal
    public static void main(String[] args) {
        menu();
    }
}
