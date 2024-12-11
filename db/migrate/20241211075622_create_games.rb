class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.integer :state
      t.string :code

      t.timestamps
    end
  end
end
