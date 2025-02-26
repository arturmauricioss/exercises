fruits = []

# Loop para inserir frutas
while True:
    fruit = input('Enter a fruit (or type "quit" to exit): ')
    if fruit.lower() == 'quit':
        break
    fruits.append(fruit)

# Imprimindo as frutas armazenadas
for i, fruit in enumerate(fruits):
    print(f'Fruit {i}: {fruit}')
