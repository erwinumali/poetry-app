class Word < ApplicationRecord
  has_and_belongs_to_many :turns

  enum :difficulty, { easy: 0, hard: 1 }, default: :easy

  scope :easy, -> { where(difficulty: :easy) }
  scope :hard, -> { where(difficulty: :hard) }
  scope :for_theme, ->(theme) { where(theme: theme) }

  validates :theme, presence: true
end
