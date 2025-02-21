require 'sqlite3'

# Conectar ao banco de dados
def conectar
  SQLite3::Database.new "banco.db"
end

# Criar tabela se não existir
def criar_tabela
  db = conectar
  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS produtos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      preco REAL NOT NULL
    );
  SQL
  db.close
end

# Criar um novo produto
def criar_produto
  print "Nome do produto: "
  nome = gets.chomp
  print "Preço do produto: "
  preco = gets.chomp.to_f

  db = conectar
  db.execute("INSERT INTO produtos (nome, preco) VALUES (?, ?)", [nome, preco])
  db.close
  puts "✅ Produto cadastrado com sucesso!"
end

# Listar todos os produtos
def listar_produtos
  db = conectar
  produtos = db.execute("SELECT * FROM produtos")
  db.close

  if produtos.empty?
    puts "📭 Nenhum produto encontrado."
  else
    puts "\n📜 Lista de Produtos:"
    produtos.each do |produto|
      # Aqui está a correção
      puts "#{produto[0]} - #{produto[1]} - R$ #{sprintf('%.2f', produto[2])}"
    end
  end
end

# Atualizar um produto existente
def atualizar_produto
  listar_produtos
  print "\nDigite o ID do produto que deseja atualizar: "
  id_produto = gets.chomp.to_i
  print "Novo nome: "
  novo_nome = gets.chomp
  print "Novo preço: "
  novo_preco = gets.chomp.to_f

  db = conectar
  db.execute("UPDATE produtos SET nome = ?, preco = ? WHERE id = ?", [novo_nome, novo_preco, id_produto])
  db.close
  puts "🔄 Produto atualizado com sucesso!"
end

# Deletar um produto
def deletar_produto
  listar_produtos
  print "\nDigite o ID do produto que deseja deletar: "
  id_produto = gets.chomp.to_i

  db = conectar
  db.execute("DELETE FROM produtos WHERE id = ?", [id_produto])
  db.close
  puts "🗑️ Produto deletado com sucesso!"
end

# Menu interativo
def menu
  criar_tabela  # Garantir que a tabela existe
  loop do
    puts "\n📌 MENU CRUD - SQLite"
    puts "1. Criar Produto"
    puts "2. Listar Produtos"
    puts "3. Atualizar Produto"
    puts "4. Deletar Produto"
    puts "5. Sair"

    print "Escolha uma opção: "
    opcao = gets.chomp.to_i

    case opcao
    when 1
      criar_produto
    when 2
      listar_produtos
    when 3
      atualizar_produto
    when 4
      deletar_produto
    when 5
      puts "🚪 Saindo..."
      break
    else
      puts "⚠️ Opção inválida! Tente novamente."
    end
  end
end

# Executar o menu
menu
