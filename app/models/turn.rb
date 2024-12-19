class Turn < ApplicationRecord
  belongs_to :game
  has_and_belongs_to_many :words

  enum :state, { active: 0, done: 1 }, default: :active

  before_create :set_words

  def end_turn!
    self.done!
    self.ended_at = Time.now

    # Delete unused words
  end

  def seconds_left
    60 - (Time.now - self.created_at).to_i
  end

  private

  def set_words
    previous_words = Word.joins(:turns).where(turns: { game_id: self.game_id })

    easy_words = (Word.all - previous_words).easy.sample(5)
    hard_words = (Word.all - previous_words).hard.sample(5)

    self.words = easy_words + hard_words
  end
end
