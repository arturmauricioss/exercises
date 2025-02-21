def parOuImpar():
    n = int(input("Digite um número: "))
    if n % 2 == 0:
        print("O número é par")
    else:
        print("O número é ímpar")
parOuImpar() 
print("Quer Continuar? (S/N)")
continuar = input()   
while continuar == "S" or continuar == "s":
    parOuImpar()
    print("Quer Continuar? (S/N)")
    continuar = input()
print("Fim do Programa")