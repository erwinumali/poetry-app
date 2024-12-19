class CreateSubTurns < ActiveRecord::Migration[8.0]
  def change
    create_table :sub_turns do |t|
      t.integer :score, default: 0
      t.string :easy_word
      t.string :hard_word
      t.integer :state

      t.belongs_to :turn
      t.timestamps
    end
  end
end
