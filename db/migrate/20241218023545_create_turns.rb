class CreateTurns < ActiveRecord::Migration[8.0]
  def change
    create_table :turns do |t|
      t.integer :state

      t.string :player_id
      t.string :judge_id
      t.integer :total_score, default: 0
      t.integer :round, default: 1

      t.belongs_to :game

      t.datetime :ended_at

      t.timestamps
    end
  end
end
