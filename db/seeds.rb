# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
#
puts 'Seeding the database...'
puts 'Creating words'

easy_words = YAML.load_file(Rails.root.join('db', 'easy_words.yml'))
easy_words['easy'].each do |word|
  Word.find_or_create_by!(word: word.downcase, difficulty: :easy)
end

hard_words = YAML.load_file(Rails.root.join('db', 'hard_words.yml'))
hard_words['hard'].each do |word|
  Word.find_or_create_by!(word: word.downcase, difficulty: :hard)
end

puts 'Create test games'
('A'..'Z').each do |letter|
  Game.create!(code: letter * 4, players: [])
end
