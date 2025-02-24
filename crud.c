#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>

sqlite3* abrirBancoDeDados() {
    sqlite3* db;
    if (sqlite3_open("banco.db", &db) != SQLITE_OK) {
        fprintf(stderr, "Erro ao abrir o banco de dados: %s\n", sqlite3_errmsg(db));
        return NULL;
    }
    return db;
}

void criarTabela(sqlite3* db) {
    const char* sql = "CREATE TABLE IF NOT EXISTS produtos (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT NOT NULL, preco REAL NOT NULL);";
    char* errMsg;
    sqlite3_exec(db, sql, NULL, NULL, &errMsg);
    if (errMsg) {
        fprintf(stderr, "Erro ao criar tabela: %s\n", errMsg);
        sqlite3_free(errMsg);
    }
}

void inserirProduto(sqlite3* db, const char* nome, double preco) {
    char sql[256];
    snprintf(sql, sizeof(sql), "INSERT INTO produtos (nome, preco) VALUES ('%s', %f);", nome, preco);
    char* errMsg;
    sqlite3_exec(db, sql, NULL, NULL, &errMsg);
    if (errMsg) {
        fprintf(stderr, "Erro ao inserir produto: %s\n", errMsg);
        sqlite3_free(errMsg);
    }
}

void listarProdutos(sqlite3* db) {
    const char* sql = "SELECT * FROM produtos;";
    sqlite3_stmt* stmt;

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int id = sqlite3_column_int(stmt, 0);
            const char* nome = (const char*)sqlite3_column_text(stmt, 1);
            double preco = sqlite3_column_double(stmt, 2);
            printf("%d - %s - R$ %.2f\n", id, nome, preco);
        }
    }
    sqlite3_finalize(stmt);
}

void fecharBancoDeDados(sqlite3* db) {
    sqlite3_close(db);
}
