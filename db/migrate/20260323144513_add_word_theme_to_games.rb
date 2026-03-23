class AddWordThemeToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :word_theme, :string, default: 'default'
  end
end
