const sqlite3 = require("sqlite3").verbose();
const readline = require("readline-sync");

// Conectar ao banco de dados
const db = new sqlite3.Database("banco.db", (err) => {
  if (err) console.error(err.message);
});

// Criar tabela se não existir
db.run(`CREATE TABLE IF NOT EXISTS produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    preco REAL NOT NULL
)`);

// Criar um novo produto
function criarProduto() {
  const nome = readline.question("Nome do produto: ");
  const preco = parseFloat(readline.question("Preço do produto: "));

  db.run(
    "INSERT INTO produtos (nome, preco) VALUES (?, ?)",
    [nome, preco],
    function (err) {
      if (err) return console.error(err.message);
      console.log("✅ Produto cadastrado com sucesso!");
    }
  );
}

// Listar todos os produtos
function listarProdutos(callback) {
  db.all("SELECT * FROM produtos", [], (err, rows) => {
    if (err) return console.error(err.message);

    if (rows.length === 0) {
      console.log("📭 Nenhum produto encontrado.");
    } else {
      console.log("\n📜 Lista de Produtos:");
      rows.forEach((produto) => {
        console.log(
          `${produto.id} - ${produto.nome} - R$ ${produto.preco.toFixed(2)}`
        );
      });
    }
    if (callback) callback();
  });
}

// Atualizar um produto
function atualizarProduto() {
  listarProdutos(() => {
    const id = readline.question(
      "\nDigite o ID do produto que deseja atualizar: "
    );
    const novoNome = readline.question("Novo nome: ");
    const novoPreco = parseFloat(readline.question("Novo preço: "));

    db.run(
      "UPDATE produtos SET nome = ?, preco = ? WHERE id = ?",
      [novoNome, novoPreco, id],
      function (err) {
        if (err) return console.error(err.message);
        console.log("🔄 Produto atualizado com sucesso!");
      }
    );
  });
}

// Deletar um produto
function deletarProduto() {
  listarProdutos(() => {
    const id = readline.question(
      "\nDigite o ID do produto que deseja deletar: "
    );

    db.run("DELETE FROM produtos WHERE id = ?", [id], function (err) {
      if (err) return console.error(err.message);
      console.log("🗑️ Produto deletado com sucesso!");
    });
  });
}

// Menu interativo
function menu() {
  while (true) {
    console.log("\n📌 MENU CRUD - SQLite");
    console.log("1. Criar Produto");
    console.log("2. Listar Produtos");
    console.log("3. Atualizar Produto");
    console.log("4. Deletar Produto");
    console.log("5. Sair");

    const opcao = readline.question("Escolha uma opção: ");

    if (opcao === "1") {
      criarProduto();
    } else if (opcao === "2") {
      listarProdutos();
    } else if (opcao === "3") {
      atualizarProduto();
    } else if (opcao === "4") {
      deletarProduto();
    } else if (opcao === "5") {
      console.log("🚪 Saindo...");
      db.close();
      break;
    } else {
      console.log("⚠️ Opção inválida! Tente novamente.");
    }
  }
}

menu();
