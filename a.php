<?php
// Função para conectar ao banco de dados SQLite
function conectar() {
    return new SQLite3("banco.db");
}

// Criar a tabela se não existir
function criarTabela() {
    $db = conectar();
    $query = "CREATE TABLE IF NOT EXISTS produtos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nome TEXT NOT NULL,
                preco REAL NOT NULL
              )";
    $db->exec($query);
    $db->close();
}

// Criar um novo produto
function criarProduto() {
    echo "Nome do produto: ";
    $nome = trim(fgets(STDIN));
    
    echo "Preço do produto: ";
    $preco = trim(fgets(STDIN));

    if (!is_numeric($preco)) {
        echo "❌ Preço inválido! Insira um número.\n";
        return;
    }

    $db = conectar();
    $stmt = $db->prepare("INSERT INTO produtos (nome, preco) VALUES (:nome, :preco)");
    $stmt->bindValue(":nome", $nome, SQLITE3_TEXT);
    $stmt->bindValue(":preco", (float)$preco, SQLITE3_FLOAT);
    $stmt->execute();
    $db->close();
    echo "✅ Produto cadastrado com sucesso!\n";
}

// Listar todos os produtos
function listarProdutos() {
    $db = conectar();
    $query = "SELECT * FROM produtos";
    $result = $db->query($query);

    echo "\n📜 Lista de Produtos:\n";
    $encontrado = false;
    
    while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
        echo "{$row['id']} - {$row['nome']} - R$ " . number_format($row['preco'], 2, ',', '.') . "\n";
        $encontrado = true;
    }
    
    if (!$encontrado) {
        echo "📭 Nenhum produto encontrado.\n";
    }

    $db->close();
}

// Atualizar um produto existente
function atualizarProduto() {
    listarProdutos();
    echo "\nDigite o ID do produto que deseja atualizar: ";
    $id = trim(fgets(STDIN));
    
    echo "Novo nome: ";
    $novoNome = trim(fgets(STDIN));
    
    echo "Novo preço: ";
    $novoPreco = trim(fgets(STDIN));

    if (!is_numeric($novoPreco)) {
        echo "❌ Preço inválido! Insira um número.\n";
        return;
    }

    $db = conectar();
    $stmt = $db->prepare("UPDATE produtos SET nome = :nome, preco = :preco WHERE id = :id");
    $stmt->bindValue(":nome", $novoNome, SQLITE3_TEXT);
    $stmt->bindValue(":preco", (float)$novoPreco, SQLITE3_FLOAT);
    $stmt->bindValue(":id", (int)$id, SQLITE3_INTEGER);
    $stmt->execute();
    $db->close();
    echo "🔄 Produto atualizado com sucesso!\n";
}

// Deletar um produto
function deletarProduto() {
    listarProdutos();
    echo "\nDigite o ID do produto que deseja deletar: ";
    $id = trim(fgets(STDIN));

    $db = conectar();
    $stmt = $db->prepare("DELETE FROM produtos WHERE id = :id");
    $stmt->bindValue(":id", (int)$id, SQLITE3_INTEGER);
    $stmt->execute();
    $db->close();
    echo "🗑️ Produto deletado com sucesso!\n";
}

// Menu interativo
function menu() {
    criarTabela(); // Garantir que a tabela existe
    while (true) {
        echo "\n📌 MENU CRUD - SQLite\n";
        echo "1. Criar Produto\n";
        echo "2. Listar Produtos\n";
        echo "3. Atualizar Produto\n";
        echo "4. Deletar Produto\n";
        echo "5. Sair\n";
        echo "Escolha uma opção: ";

        $opcao = trim(fgets(STDIN));

        switch ($opcao) {
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
                echo "🚪 Saindo...\n";
                exit;
            default:
                echo "⚠️ Opção inválida! Tente novamente.\n";
        }
    }
}

// Executar o menu
menu();
?>