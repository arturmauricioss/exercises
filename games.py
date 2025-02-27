import os
import random
import platform

class MeusJogos:
    def __init__(self):
        self.opcoes = {
            "1": self.jogo_da_velha,
            "2": self.campo_minado,
            "3": self.jogo_da_memoria,
            "4": self.jogo_da_forca,
            "5": self.sair
        }

    def exibir_menu(self):
        print("\n----- MENU -----")
        print("1 - Jogo da Velha")
        print("2 - Campo Minado")
        print("3 - Jogo da Memória")
        print("4 - Jogo da Forca")
        print("5 - Sair")

    def escolher_jogo(self):
        while True:
            self.exibir_menu()
            escolha = input("Escolha um jogo: ")
            if escolha in self.opcoes:
                self.opcoes[escolha]()
            else:
                print("Opção inválida! Tente novamente.")

    def limpar_tela(self):
        """Limpa a tela do console."""
        if platform.system() == "Windows":
            os.system("cls")  # Comando para Windows
        else:
            os.system("clear")  # Comando para Linux/Mac

    def exibir_tabuleiro(self, tabuleiro):
        """Exibe o tabuleiro formatado."""
        for i, linha in enumerate(tabuleiro):
            print("  " + "  |  ".join(linha))
            if i < 2:
                print("-----+-----+-----")

    def jogo_da_velha(self):
        print("\n🎮 Jogo da Velha 🎮")

        # Criando um tabuleiro numerado de 1 a 9
        tabuleiro = [[str(i + j * 3) for i in range(1, 4)] for j in range(3)]

        # Sorteando quem começa
        jogador_atual = random.choice(["X", "O"])
        print(f"\n🔄 Sorteio: {jogador_atual} começa!")

        def verificar_vencedor():
            """Verifica se há um vencedor no tabuleiro."""
            for linha in tabuleiro:
                if linha[0] == linha[1] == linha[2] and linha[0] in ["X", "O"]:
                    return linha[0]

            for col in range(3):
                if tabuleiro[0][col] == tabuleiro[1][col] == tabuleiro[2][col] and tabuleiro[0][col] in ["X", "O"]:
                    return tabuleiro[0][col]

            if tabuleiro[0][0] == tabuleiro[1][1] == tabuleiro[2][2] and tabuleiro[0][0] in ["X", "O"]:
                return tabuleiro[0][0]

            if tabuleiro[0][2] == tabuleiro[1][1] == tabuleiro[2][0] and tabuleiro[0][2] in ["X", "O"]:
                return tabuleiro[0][2]

            return None

        for _ in range(9):
            self.limpar_tela()  # Limpa a tela antes de exibir o tabuleiro
            self.exibir_tabuleiro(tabuleiro)

            while True:
                try:
                    escolha = int(input(f"\n{jogador_atual}, escolha um número (1-9): "))
                    if escolha < 1 or escolha > 9:
                        raise ValueError
                    linha, coluna = (escolha - 1) // 3, (escolha - 1) % 3
                    if tabuleiro[linha][coluna] in ["X", "O"]:
                        print("❌ Espaço já ocupado! Escolha outro.")
                    else:
                        break
                except ValueError:
                    print("⚠ Entrada inválida! Escolha um número de 1 a 9.")

            tabuleiro[linha][coluna] = jogador_atual

            vencedor = verificar_vencedor()
            if vencedor:
                self.limpar_tela()  # Limpa a tela antes de exibir o vencedor
                self.exibir_tabuleiro(tabuleiro)
                print(f"\n🏆 {vencedor} venceu! Parabéns! 🎉")
                break

            jogador_atual = "O" if jogador_atual == "X" else "X"  # Alterna o jogador

        else:
            self.limpar_tela()  # Limpa a tela antes de exibir empate
            self.exibir_tabuleiro(tabuleiro)
            print("\n⚖️ Empate! Ninguém venceu.")

        # Perguntar se o jogador quer voltar ao menu ou jogar novamente
        while True:
            escolha = input("\nDigite [M] para voltar ao menu ou [J] para jogar novamente: ").strip().upper()
            if escolha == "M":
                return  # Volta ao menu
            elif escolha == "J":
                self.jogo_da_velha()  # Reinicia o jogo
            else:
                print("Opção inválida! Tente novamente.")

    def campo_minado(self):
        print("\n💣 Campo Minado 💣")

    def jogo_da_memoria(self):
        print("\n🧠 Jogo da Memória 🧠")

    def jogo_da_forca(self):
        print("\n🔠 Jogo da Forca 🔠")

    def sair(self):
        print("\nSaindo... Até mais! 👋")
        exit()

# Criando e executando o menu
menu = MeusJogos()
menu.escolher_jogo()
