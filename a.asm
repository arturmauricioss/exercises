section .data
    db_nome db "Produto1", 0        ; Nome do produto
    db_preco dq 10.5                ; Preço do produto

section .bss
    db_handle resq 1                ; Espaço para o ponteiro do banco de dados

section .text
    extern abrirBancoDeDados
    extern criarTabela
    extern inserirProduto
    extern listarProdutos
    extern fecharBancoDeDados
    global _start

_start:
    ; Abrir o banco de dados
    call abrirBancoDeDados
    mov [db_handle], rax

    ; Criar tabela
    mov rdi, [db_handle]
    call criarTabela

    ; Inserir produto
    mov rdi, [db_handle]
    mov rsi, db_nome
    mov rdx, [db_preco]
    call inserirProduto

    ; Listar produtos
    mov rdi, [db_handle]
    call listarProdutos

    ; Fechar banco de dados
    mov rdi, [db_handle]
    call fecharBancoDeDados

    ; Sair do programa
    mov rax, 60         ; syscall: exit
    xor rdi, rdi        ; status: 0
    syscall
