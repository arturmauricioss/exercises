defmodule CRUDSQLite.CLI do
  alias CRUDSQLite.{Repo, Produto}

  def menu do
    create_table()

    loop()
  end

  defp loop do
    IO.puts("\n📌 MENU CRUD - SQLite")
    IO.puts("1. Criar Produto")
    IO.puts("2. Listar Produtos")
    IO.puts("3. Atualizar Produto")
    IO.puts("4. Deletar Produto")
    IO.puts("5. Sair")

    case IO.gets("Escolha uma opção: ") do
      "1\n" -> criar_produto() && loop()
      "2\n" -> listar_produtos() && loop()
      "3\n" -> atualizar_produto() && loop()
      "4\n" -> deletar_produto() && loop()
      "5\n" -> IO.puts("🚪 Saindo...")
      _ -> IO.puts("⚠️ Opção inválida!") && loop()
    end
  end

  defp create_table do
    Repo.start_link()
    :ok
  end

  defp criar_produto do
    nome = IO.gets("Nome do produto: ") |> String.trim()
    preco = IO.gets("Preço do produto: ") |> String.trim() |> String.to_float()

    %Produto{}
    |> Produto.changeset(%{nome: nome, preco: preco})
    |> Repo.insert()

    IO.puts("✅ Produto cadastrado com sucesso!")
  end

  defp listar_produtos do
    produtos = Repo.all(Produto)

    if produtos == [] do
      IO.puts("📭 Nenhum produto encontrado.")
    else
      IO.puts("\n📜 Lista de Produtos:")
      Enum.each(produtos, fn produto ->
        IO.puts("#{produto.id} - #{produto.nome} - R$ #{produto.preco}")
      end)
    end
  end

  defp atualizar_produto do
    listar_produtos()
    id = IO.gets("\nDigite o ID do produto que deseja atualizar: ") |> String.trim() |> String.to_integer()
    novo_nome = IO.gets("Novo nome: ") |> String.trim()
    novo_preco = IO.gets("Novo preço: ") |> String.trim() |> String.to_float()

    produto = Repo.get!(Produto, id)

    produto
    |> Produto.changeset(%{nome: novo_nome, preco: novo_preco})
    |> Repo.update()

    IO.puts("🔄 Produto atualizado com sucesso!")
  end

  defp deletar_produto do
    listar_produtos()
    id = IO.gets("\nDigite o ID do produto que deseja deletar: ") |> String.trim() |> String.to_integer()

    produto = Repo.get!(Produto, id)

    Repo.delete(produto)
    IO.puts("🗑️ Produto deletado com sucesso!")
  end
end
