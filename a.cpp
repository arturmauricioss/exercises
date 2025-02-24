#include <iostream>
#include <sqlite3.h>

using namespace std;

// Função para criar ou abrir o banco de dados
sqlite3* abrirBancoDeDados() {
    sqlite3* db;
    int resultado = sqlite3_open("banco.db", &db);
    
    if (resultado) {
        cerr << "Erro ao abrir o banco de dados: " << sqlite3_errmsg(db) << endl;
        return nullptr;
    }
    return db;
}

// Função para criar a tabela se não existir
void criarTabela(sqlite3* db) {
    const char* sql = R"(
        CREATE TABLE IF NOT EXISTS produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
        );
    )";

    char* erroMsg;
    if (sqlite3_exec(db, sql, nullptr, nullptr, &erroMsg) != SQLITE_OK) {
        cerr << "Erro ao criar tabela: " << erroMsg << endl;
        sqlite3_free(erroMsg);
    }
}

// Função para criar um novo produto
void criarProduto(sqlite3* db) {
    string nome;
    double preco;

    cout << "Nome do produto: ";
    cin >> nome;
    cout << "Preço do produto: ";
    cin >> preco;

    string sql = "INSERT INTO produtos (nome, preco) VALUES ('" + nome + "', " + to_string(preco) + ");";
    
    char* erroMsg;
    if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &erroMsg) != SQLITE_OK) {
        cerr << "Erro ao inserir produto: " << erroMsg << endl;
        sqlite3_free(erroMsg);
    } else {
        cout << "✅ Produto cadastrado com sucesso!" << endl;
    }
}

// Função para listar todos os produtos
void listarProdutos(sqlite3* db) {
    const char* sql = "SELECT * FROM produtos;";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, nullptr) != SQLITE_OK) {
        cerr << "Erro ao preparar a consulta: " << sqlite3_errmsg(db) << endl;
        return;
    }

    cout << "\n📜 Lista de Produtos:" << endl;
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int id = sqlite3_column_int(stmt, 0);
        const char* nome = (const char*)sqlite3_column_text(stmt, 1);
        double preco = sqlite3_column_double(stmt, 2);
        cout << id << " - " << nome << " - R$ " << preco << endl;
    }

    sqlite3_finalize(stmt);
}

// Função para atualizar um produto existente
void atualizarProduto(sqlite3* db) {
    listarProdutos(db);
    int id;
    string novoNome;
    double novoPreco;

    cout << "\nDigite o ID do produto que deseja atualizar: ";
    cin >> id;
    cout << "Novo nome: ";
    cin >> novoNome;
    cout << "Novo preço: ";
    cin >> novoPreco;

    string sql = "UPDATE produtos SET nome = '" + novoNome + "', preco = " + to_string(novoPreco) + " WHERE id = " + to_string(id) + ";";

    char* erroMsg;
    if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &erroMsg) != SQLITE_OK) {
        cerr << "Erro ao atualizar produto: " << erroMsg << endl;
        sqlite3_free(erroMsg);
    } else {
        cout << "🔄 Produto atualizado com sucesso!" << endl;
    }
}

// Função para deletar um produto
void deletarProduto(sqlite3* db) {
    listarProdutos(db);
    int id;

    cout << "\nDigite o ID do produto que deseja deletar: ";
    cin >> id;

    string sql = "DELETE FROM produtos WHERE id = " + to_string(id) + ";";

    char* erroMsg;
    if (sqlite3_exec(db, sql.c_str(), nullptr, nullptr, &erroMsg) != SQLITE_OK) {
        cerr << "Erro ao deletar produto: " << erroMsg << endl;
        sqlite3_free(erroMsg);
    } else {
        cout << "🗑️ Produto deletado com sucesso!" << endl;
    }
}

// Função principal
int main() {
    sqlite3* db = abrirBancoDeDados();
    if (!db) return 1;

    criarTabela(db);

    while (true) {
        cout << "\n📌 MENU CRUD - SQLite" << endl;
        cout << "1. Criar Produto" << endl;
        cout << "2. Listar Produtos" << endl;
        cout << "3. Atualizar Produto" << endl;
        cout << "4. Deletar Produto" << endl;
        cout << "5. Sair" << endl;

        cout << "Escolha uma opção: ";
        int opcao;
        cin >> opcao;

        switch (opcao) {
            case 1:
                criarProduto(db);
                break;
            case 2:
                listarProdutos(db);
                break;
            case 3:
                atualizarProduto(db);
                break;
            case 4:
                deletarProduto(db);
                break;
            case 5:
                cout << "🚪 Saindo..." << endl;
                sqlite3_close(db);
                return 0;
            default:
                cout << "⚠️ Opção inválida! Tente novamente." << endl;
                break;
        }
    }
}
