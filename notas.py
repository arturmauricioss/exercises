print('Escreve sua nota: ')
nota = float(input().replace(',', '.'))
nota = round(nota, 2)
case = {
    0 <= nota <= 5.9: 'F',
    6 <= nota <= 6.2: 'D-',
    6.3 <= nota <= 6.6: 'D',
    6.7 <= nota <= 6.9: 'D+',
    7 <= nota <= 7.2: 'C-',
    7.3 <= nota <= 7.6: 'C',
    7.7 <= nota <= 7.9: 'C+',
    8 <= nota <= 8.2: 'B-',
    8.3 <= nota <= 8.6: 'B',
    8.7 <= nota <= 8.9: 'B+',
    9 <= nota <= 9.2: 'A-',
    9.3 <= nota <= 9.6: 'A',
    9.7 <= nota <= 10: 'A+'
}