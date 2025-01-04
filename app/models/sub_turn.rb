class SubTurn < ApplicationRecord
  belongs_to :turn
  delegate :game, to: :turn

  enum :state, { active: 0, done: 1 }, default: :active
  enum :skip_type, { score: 0, skip: 1, bonk: 2 }, default: :none
end
