class AddThemeToWords < ActiveRecord::Migration[8.0]
  def change
    add_column :words, :theme, :string
  end
end
