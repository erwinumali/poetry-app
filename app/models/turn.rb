class Turn < ApplicationRecord
  include Scoring

  belongs_to :game
  has_many :sub_turns
  has_and_belongs_to_many :words

  enum :state, { active: 0, done: 1 }, default: :active

  before_create :set_words
  after_create :create_sub_turn

  def next_sub_turn(type)
    return if self.expired?

    update_total_score(type)

    previous_sub_turn = self.current_sub_turn
    self.current_sub_turn.done!

    if self.words.count < 2
      broadcast_empty_sub_turn(previous_sub_turn)
    else
      self.create_sub_turn

      broadcast_sub_turn(previous_sub_turn, type == 'bonk')
    end
  end

  def end_turn!
    update_total_score('end_turn')

    self.done!
    self.ended_at = Time.now

    # Clear unused words
    self.words = []
    self.save
  end

  def milliseconds_left
    self.game.time_per_turn - ( (Time.now - self.created_at).to_f * 1000 ).floor
  end

  def create_sub_turn
    easy_word = self.words.easy.sample
    self.words.delete(easy_word)

    hard_word = self.words.hard.sample
    self.words.delete(hard_word)

    self.sub_turns.create(easy_word: easy_word.word, hard_word: hard_word.word)
  end

  def current_sub_turn
    self.sub_turns.active.first
  end

  def current_player
    @current_player ||= self.game.players.find { |player| player[:id] == self.player_id }
  end

  def current_judge
    @current_judge ||= self.game.players.find { |player| player[:id] == self.judge_id }
  end

  def expired?
    # Within a second
    self.active? && self.milliseconds_left < -1000
  end

  # Only end the turn if the turn has expired or
  # the turn has ran out of words
  def endable?
    self.active? &&
      ( self.milliseconds_left < 500 || self.words.count < 2 )
  end

  private

  def broadcast_sub_turn(previous_sub_turn, bonk)
    [:current, :judge].each do |player_type|
      broadcast_replace_to "turn_#{self.id}_#{player_type}",
        target: "sub_turn_#{previous_sub_turn.id}",
        partial: 'turns/sub_turn', locals: { sub_turn: self.current_sub_turn, bonk: bonk, player_type: player_type }
    end
  end

  def broadcast_empty_sub_turn(previous_sub_turn)
    [:current, :judge].each do |player_type|
      broadcast_replace_to "turn_#{self.id}_#{player_type}",
        target: "sub_turn_#{previous_sub_turn.id}",
        partial: 'turns/empty_sub_turn'
    end
  end

  def set_words
    previous_words = SubTurn.joins(:turn).where(turns: { game_id: self.game_id }).pluck(:easy_word, :hard_word).flatten

    easy_words = Word.all.where.not(word: previous_words).easy.sample(20)
    hard_words = Word.all.where.not(word: previous_words).hard.sample(20)

    self.words = easy_words + hard_words
  end
end
