#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>

// Função para criar ou abrir o banco de dados
sqlite3* abrirBancoDeDados() {
    sqlite3* db;
    int resultado = sqlite3_open("banco.db", &db);

    if (resultado) {
        fprintf(stderr, "Erro ao abrir o banco de dados: %s\n", sqlite3_errmsg(db));
        return NULL;
    }
    return db;
}

// Função para criar a tabela se não existir
void criarTabela(sqlite3* db) {
    const char* sql = "CREATE TABLE IF NOT EXISTS produtos ("
                      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                      "nome TEXT NOT NULL,"
                      "preco REAL NOT NULL);";

    char* erroMsg;
    if (sqlite3_exec(db, sql, NULL, NULL, &erroMsg) != SQLITE_OK) {
        fprintf(stderr, "Erro ao criar tabela: %s\n", erroMsg);
        sqlite3_free(erroMsg);
    }
}

// Função para criar um novo produto
void criarProduto(sqlite3* db) {
    char nome[100];
    double preco;

    printf("Nome do produto: ");
    scanf("%s", nome);
    printf("Preço do produto: ");
    scanf("%lf", &preco);

    char sql[256];
    snprintf(sql, sizeof(sql), "INSERT INTO produtos (nome, preco) VALUES ('%s', %f);", nome, preco);

    char* erroMsg;
    if (sqlite3_exec(db, sql, NULL, NULL, &erroMsg) != SQLITE_OK) {
        fprintf(stderr, "Erro ao inserir produto: %s\n", erroMsg);
        sqlite3_free(erroMsg);
    } else {
        printf("✅ Produto cadastrado com sucesso!\n");
    }
}

// Função para listar todos os produtos
void listarProdutos(sqlite3* db) {
    const char* sql = "SELECT * FROM produtos;";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        fprintf(stderr, "Erro ao preparar a consulta: %s\n", sqlite3_errmsg(db));
        return;
    }

    printf("\n📜 Lista de Produtos:\n");
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        int id = sqlite3_column_int(stmt, 0);
        const char* nome = (const char*)sqlite3_column_text(stmt, 1);
        double preco = sqlite3_column_double(stmt, 2);
        printf("%d - %s - R$ %.2f\n", id, nome, preco);
    }

    sqlite3_finalize(stmt);
}

// Função para atualizar um produto existente
void atualizarProduto(sqlite3* db) {
    listarProdutos(db);
    int id;
    char novoNome[100];
    double novoPreco;

    printf("\nDigite o ID do produto que deseja atualizar: ");
    scanf("%d", &id);
    printf("Novo nome: ");
    scanf("%s", novoNome);
    printf("Novo preço: ");
    scanf("%lf", &novoPreco);

    char sql[256];
    snprintf(sql, sizeof(sql), "UPDATE produtos SET nome = '%s', preco = %f WHERE id = %d;", novoNome, novoPreco, id);

    char* erroMsg;
    if (sqlite3_exec(db, sql, NULL, NULL, &erroMsg) != SQLITE_OK) {
        fprintf(stderr, "Erro ao atualizar produto: %s\n", erroMsg);
        sqlite3_free(erroMsg);
    } else {
        printf("🔄 Produto atualizado com sucesso!\n");
    }
}

// Função para deletar um produto
void deletarProduto(sqlite3* db) {
    listarProdutos(db);
    int id;

    printf("\nDigite o ID do produto que deseja deletar: ");
    scanf("%d", &id);

    char sql[256];
    snprintf(sql, sizeof(sql), "DELETE FROM produtos WHERE id = %d;", id);

    char* erroMsg;
    if (sqlite3_exec(db, sql, NULL, NULL, &erroMsg) != SQLITE_OK) {
        fprintf(stderr, "Erro ao deletar produto: %s\n", erroMsg);
        sqlite3_free(erroMsg);
    } else {
        printf("🗑️ Produto deletado com sucesso!\n");
    }
}

// Função principal
int main() {
    sqlite3* db = abrirBancoDeDados();
    if (!db) return 1;

    criarTabela(db);

    while (1) {
        printf("\n📌 MENU CRUD - SQLite\n");
        printf("1. Criar Produto\n");
        printf("2. Listar Produtos\n");
        printf("3. Atualizar Produto\n");
        printf("4. Deletar Produto\n");
        printf("5. Sair\n");

        printf("Escolha uma opção: ");
        int opcao;
        scanf("%d", &opcao);

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
                printf("🚪 Saindo...\n");
                sqlite3_close(db);
                return 0;
            default:
                printf("⚠️ Opção inválida! Tente novamente.\n");
                break;
        }
    }
}
