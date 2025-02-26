import time
from typing import List

# class Solution:
#     def twoSum(self, nums: List[int], target: int) -> List[int]:
#         num_map = {}  # Dicionário para armazenar número e seu índice
#         print("Dicionário inicializado:", num_map)
#         time.sleep(3)

#         for i, num in enumerate(nums):
#             complement = target - num
#             print(f"Passo {i + 1}:")
#             print(f"  Número atual: {num} (Índice: {i})")
#             print(f"  Complemento necessário: {complement}")
#             time.sleep(3)

#             if complement in num_map:
#                 print(f"  Complemento {complement} encontrado no dicionário!")
#                 print(f"  Retornando índices: [{num_map[complement]}, {i}]")
#                 return [num_map[complement], i]

#             num_map[num] = i  # Armazena índice do número atual
#             print(f"  Adicionando {num}: {i} ao dicionário -> {num_map}")
#             time.sleep(3)

#         return []  # Nunca deve chegar aqui, conforme as restrições do problema

# # Entrada do usuário
# print("Digite os números da lista separados por espaço:")
# nums = list(map(int, input().split()))
# print("Digite o alvo:")
# target = int(input())

# sol = Solution()
# resultado = sol.twoSum(nums, target)
# print("Resultado final:", resultado)


print("Digite os números da lista separados por espaço:")
input_list = list(map(int, input().split()))  # Converte a entrada para uma lista de inteiros

for index, value in enumerate(input_list):  # Usando enumerate corretamente
    print(f"Índice {index}: Valor {value}")
