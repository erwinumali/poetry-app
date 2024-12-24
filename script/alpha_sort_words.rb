require 'yaml'

easy_words = YAML.load_file('db/easy_words.yml')

easy_words = easy_words['easy'].map(&:downcase).sort.uniq
File.open('db/new_easy_words.yml', 'w') { |f| f.write({ 'easy' => easy_words }.to_yaml) }

hard_words = YAML.load_file('db/hard_words.yml')
hard_words = hard_words['hard'].map(&:downcase).sort.uniq
File.open('db/new_hard_words.yml', 'w') { |f| f.write({ 'hard' => hard_words }.to_yaml) }
