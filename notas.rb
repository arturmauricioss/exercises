print "Digite sua nota: "
nota = gets.chomp.tr(',', '.').to_f  # Substitui vírgula por ponto e converte para float

conceito = case nota
  when 9.7..10 then "A+"
  when 9.3..9.6 then "A"
  when 9.0..9.2 then "A-"
  when 8.7..8.9 then "B+"
  when 8.3..8.6 then "B"
  when 8.0..8.2 then "B-"
  when 7.7..7.9 then "C+"
  when 7.3..7.6 then "C"
  when 7.0..7.2 then "C-"
  when 6.7..6.9 then "D+"
  when 6.3..6.6 then "D"
  when 6.0..6.2 then "D-"
  when 0..5.9 then "F"
  else "Nota inválida"
end

puts "Nota conceito: #{conceito}"
