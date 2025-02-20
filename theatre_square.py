import math

def azulejando_com_quebras_exatas(n, m, a, b):
    # Azulejos inteiros (não quebrados)
    azulejos_inteiros = (n // a) * (m // b)
    
    # O total de azulejos que seriam necessários (se não houvesse quebras)
    azulejos_totais = math.ceil(n / a) * math.ceil(m / b)
    
    # Azulejos quebrados
    azulejos_quebrados = azulejos_totais - azulejos_inteiros
    
    # Determina a sobra nas bordas
    sobra_n = n % a  # Sobra na altura
    sobra_m = m % b  # Sobra na largura
    
    # Lista para armazenar as quebras (dimensões dos pedaços quebrados)
    quebras = []
    
    # Se houver sobra na altura (n % a) ou na largura (m % b), calculamos a quebra
    if sobra_n > 0 and sobra_m > 0:
        quebras.append(f"Quebra na quina: {sobra_n}x{sobra_m} (pedaço único)")
    
    # Se houver sobra apenas na altura
    elif sobra_n > 0:
        quebras.append(f"Quebra na altura: {sobra_n}x{b} (pedaço horizontal)")
    
    # Se houver sobra apenas na largura
    elif sobra_m > 0:
        quebras.append(f"Quebra na largura: {a}x{sobra_m} (pedaço vertical)")
    
    # Se houver espaço restante que pode ser preenchido com metade de um azulejo
    if sobra_n > 0 and sobra_m > 0:
        quebras.append(f"Metade de azulejo: {min(sobra_n, a)}x{min(sobra_m, b)}")
    
    return azulejos_inteiros, azulejos_quebrados, quebras


# Exemplo de uso:
n = float(input("Informe o valor do comprimento da área (em metros): "))
m = float(input("Informe o valor da largura da área (em metros): "))
a = float(input("Informe o valor da altura do azulejo (em metros): "))
b = float(input("Informe o valor da largura do azulejo (em metros): "))

# Chamada da função para calcular azulejos inteiros, quebrados e os detalhes das quebras
azulejos_inteiros, azulejos_quebrados, quebras = azulejando_com_quebras_exatas(n, m, a, b)

# Exibir o resultado
print(f"Azulejos inteiros necessários: {azulejos_inteiros}")
print(f"Azulejos quebrados necessários: {azulejos_quebrados}")
print("Detalhes das quebras:")
for quebra in quebras:
    print(quebra)
