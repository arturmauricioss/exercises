print('quanto quero de imprestimo?')
emprestimo = float(input())
juros = 0.2
valorComJuros = emprestimo * (1+ juros)
print('com quantas parcelas quero pagar?')
parcelas = int(input())
valorParcela = valorComJuros / parcelas
print('você terá que pagar',valorParcela,'por',parcelas,'meses. A taxa de juros é de',juros*100,'%')

