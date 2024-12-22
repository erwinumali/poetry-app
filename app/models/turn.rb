class Turn < ApplicationRecord
  include Scoring

  belongs_to :game
  has_many :sub_turns
  has_and_belongs_to_many :words

  enum :state, { active: 0, done: 1 }, default: :active

  before_create :set_words
  after_create :create_sub_turn

  def update_total_score(type)
    if type == 'bonk'
      self.total_score -= 1
      self.current_sub_turn.update(score: -1)
    else
      # Skip (-1)
      if self.current_sub_turn.score == 0
        self.total_score -= 1
        self.current_sub_turn.update(score: -1)
      # Pass
      else
        self.total_score += self.current_sub_turn.score
      end
    end

    self.save
  end

  def next_sub_turn(type)
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
    self.done!
    self.ended_at = Time.now

    # Clear unused words
    self.words = []
    self.save
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
    self.active? && self.seconds_left < 0
  end

  private

  def broadcast_sub_turn(previous_sub_turn, bonk)
    broadcast_replace_to self.game,
      target: "sub_turn_#{previous_sub_turn.id}",
      partial: 'turns/sub_turn', locals: { sub_turn: self.current_sub_turn, bonk: bonk }
  end

  def broadcast_empty_sub_turn(previous_sub_turn)
    broadcast_replace_to self.game,
      target: "sub_turn_#{previous_sub_turn.id}",
      partial: 'turns/empty_sub_turn'
  end

  def set_words
    previous_words = SubTurn.joins(:turn).where(turns: { game_id: self.game_id }).pluck(:easy_word, :hard_word).flatten

    easy_words = Word.all.where.not(word: previous_words).easy.sample(20)
    hard_words = Word.all.where.not(word: previous_words).hard.sample(20)

    self.words = easy_words + hard_words
  end
end
