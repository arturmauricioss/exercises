import sqlite3

# Função para conectar ao banco de dados
def conectar():
    return sqlite3.connect("banco.db")

# Criar a tabela se não existir
def criar_tabela():
    conn = conectar()
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS produtos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            preco REAL NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

# Criar um novo produto
def criar_produto():
    nome = input("Nome do produto: ")
    preco = float(input("Preço do produto: "))
    
    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO produtos (nome, preco) VALUES (?, ?)", (nome, preco))
    conn.commit()
    conn.close()
    print("✅ Produto cadastrado com sucesso!")
    

# Listar todos os produtos
def listar_produtos():
    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM produtos")
    produtos = cursor.fetchall()
    conn.close()

    if not produtos:
        print("📭 Nenhum produto encontrado.")
    else:
        print("\n📜 Lista de Produtos:")
        for produto in produtos:
            print(f"{produto[0]} - {produto[1]} - R$ {produto[2]:.2f}")

# Atualizar um produto existente
def atualizar_produto():
    listar_produtos()
    id_produto = input("\nDigite o ID do produto que deseja atualizar: ")
    novo_nome = input("Novo nome: ")
    novo_preco = float(input("Novo preço: "))

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("UPDATE produtos SET nome = ?, preco = ? WHERE id = ?", (novo_nome, novo_preco, id_produto))
    conn.commit()
    conn.close()
    print("🔄 Produto atualizado com sucesso!")

# Deletar um produto
def deletar_produto():
    listar_produtos()
    id_produto = input("\nDigite o ID do produto que deseja deletar: ")

    conn = conectar()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM produtos WHERE id = ?", (id_produto,))
    conn.commit()
    conn.close()
    print("🗑️ Produto deletado com sucesso!")

# Menu interativo
def menu():
    criar_tabela()  # Garantir que a tabela existe
    while True:
        print("\n📌 MENU CRUD - SQLite")
        print("1. Criar Produto")
        print("2. Listar Produtos")
        print("3. Atualizar Produto")
        print("4. Deletar Produto")
        print("5. Sair")

        opcao = input("Escolha uma opção: ")

        if opcao == "1":
            criar_produto()
        elif opcao == "2":
            listar_produtos()
        elif opcao == "3":
            atualizar_produto()
        elif opcao == "4":
            deletar_produto()
        elif opcao == "5":
            print("🚪 Saindo...")
            break
        else:
            print("⚠️ Opção inválida! Tente novamente.")

# Executar o menu
menu()
