print('Digite seu peso: ')
peso = float(input().replace(',', '.'))
print('Digite sua altura: ')
altura = float(input().replace(',', '.'))
imc = peso / (altura ** 2)
imc_formatado = round(imc, 2)
if imc < 18.5:
    print('Abaixo do peso')
elif imc < 24.9:
    print('Peso normal')
elif imc < 29.9:
    print('Sobrepeso')
elif imc < 34.9:
    print('Obesidade grau 1')
elif imc < 39.9:
    print('Obesidade grau 2')
else:
    print('Obesidade grau 3')
print('IMC: ', imc_formatado)