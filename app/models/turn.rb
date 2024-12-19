class Turn < ApplicationRecord
  belongs_to :game
  has_many :sub_turns
  has_and_belongs_to_many :words

  enum :state, { active: 0, done: 1 }, default: :active

  before_create :set_words
  after_create :create_sub_turn

  def end_turn!
    self.done!
    self.ended_at = Time.now
  end

  def seconds_left
    self.game.time_per_turn - (Time.now - self.created_at).to_i
  end

  def create_sub_turn
    easy_word = self.words.easy.sample
    self.words.delete(easy_word)

    hard_word = self.words.hard.sample
    self.words.delete(hard_word)

    self.sub_turns.create(easy_word: easy_word.word, hard_word: hard_word.word)
  end

  private

  def set_words
    previous_words = Word.joins(:turns).where(turns: { game_id: self.game_id })

    easy_words = (Word.all.easy - previous_words).sample(5)
    hard_words = (Word.all.hard - previous_words).sample(5)

    self.words = easy_words + hard_words
  end
end
