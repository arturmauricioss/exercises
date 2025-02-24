use rusqlite::{params, Connection, Result};
use std::io::{self, Write};

// Conectar ao banco de dados
fn conectar() -> Result<Connection> {
    Connection::open("banco.db")
}

// Criar tabela se não existir
fn criar_tabela() -> Result<()> {
    let conn = conectar()?;
    conn.execute(
        "CREATE TABLE IF NOT EXISTS produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
        )",
        [],
    )?;
    Ok(())
}

// Criar um novo produto
fn criar_produto() -> Result<()> {
    let mut nome = String::new();
    let mut preco = String::new();

    print!("Nome do produto: ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut nome).unwrap();

    print!("Preço do produto: ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut preco).unwrap();
    let preco: f64 = preco.trim().parse().unwrap();

    let conn = conectar()?;
    conn.execute("INSERT INTO produtos (nome, preco) VALUES (?, ?)", params![nome.trim(), preco])?;
    println!("✅ Produto cadastrado com sucesso!");
    Ok(())
}

// Listar todos os produtos
fn listar_produtos() -> Result<()> {
    let conn = conectar()?;
    let mut stmt = conn.prepare("SELECT id, nome, preco FROM produtos")?;
    let produtos = stmt.query_map([], |row| {
        Ok((row.get::<_, i32>(0)?, row.get::<_, String>(1)?, row.get::<_, f64>(2)?))
    })?;
    
    println!("\n📜 Lista de Produtos:");
    for produto in produtos {
        let (id, nome, preco) = produto?;
        println!("{} - {} - R$ {:.2}", id, nome, preco);
    }
    Ok(())
}

// Atualizar um produto
fn atualizar_produto() -> Result<()> {
    listar_produtos()?;
    let mut id = String::new();
    let mut nome = String::new();
    let mut preco = String::new();
    
    print!("\nDigite o ID do produto que deseja atualizar: ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut id).unwrap();
    let id: i32 = id.trim().parse().unwrap();
    
    print!("Novo nome: ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut nome).unwrap();
    
    print!("Novo preço: ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut preco).unwrap();
    let preco: f64 = preco.trim().parse().unwrap();

    let conn = conectar()?;
    conn.execute("UPDATE produtos SET nome = ?, preco = ? WHERE id = ?", params![nome.trim(), preco, id])?;
    println!("🔄 Produto atualizado com sucesso!");
    Ok(())
}

// Deletar um produto
fn deletar_produto() -> Result<()> {
    listar_produtos()?;
    let mut id = String::new();
    
    print!("\nDigite o ID do produto que deseja deletar: ");
    io::stdout().flush().unwrap();
    io::stdin().read_line(&mut id).unwrap();
    let id: i32 = id.trim().parse().unwrap();

    let conn = conectar()?;
    conn.execute("DELETE FROM produtos WHERE id = ?", params![id])?;
    println!("🗑️ Produto deletado com sucesso!");
    Ok(())
}

// Menu interativo
fn menu() -> Result<()> {
    criar_tabela()?;
    loop {
        println!("\n📌 MENU CRUD - SQLite");
        println!("1. Criar Produto");
        println!("2. Listar Produtos");
        println!("3. Atualizar Produto");
        println!("4. Deletar Produto");
        println!("5. Sair");
        
        let mut opcao = String::new();
        print!("Escolha uma opção: ");
        io::stdout().flush().unwrap();
        io::stdin().read_line(&mut opcao).unwrap();
        
        match opcao.trim() {
            "1" => criar_produto()?,
            "2" => listar_produtos()?,
            "3" => atualizar_produto()?,
            "4" => deletar_produto()?,
            "5" => {
                println!("🚪 Saindo...");
                break;
            }
            _ => println!("⚠️ Opção inválida! Tente novamente."),
        }
    }
    Ok(())
}

fn main() {
    if let Err(err) = menu() {
        eprintln!("Erro: {}", err);
    }
}