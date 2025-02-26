def calcular_divisao(a, b):
    resultado = a / b
    return resultado

if __name__ == "__main__":
    num1 = 10
    num2 = 2  # Isso causará um erro de divisão por zero
    print(calcular_divisao(num1, num2))

