class SubTurn < ApplicationRecord
  belongs_to :turn

  enum :state, { active: 0, done: 1 }, default: :active
end
