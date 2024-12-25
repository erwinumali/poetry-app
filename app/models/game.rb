class Game < ApplicationRecord
  include Lobby

  has_many :turns

  serialize :players

  enum :state, { waiting: 0, ready: 1, player_turn: 2, finished: 3 }, default: :waiting

  before_validation :generate_code, if: -> { self.code.nil? }

  validates :code, presence: true, uniqueness: true 

  def prepare!
    self.shuffle_players!

    self.ready!

    broadcast_update target: "container_game_#{self.id}", partial: 'games/ready', locals: { game: self }
  end

  def start_game!
    # If the rounds have exceeded the max rounds
    if current_round > self.rounds ||
        # If the game is already finished
        self.finished? ||
        # If there's already an active turn
        (self.current_turn && !self.current_turn.expired?)
      return
    end

    create_turn!
  end

  def create_turn!
    self.player_turn!

    current_player, judge_player = next_players

    turn = self.turns.create(
      player_id: current_player[:id],
      judge_id: judge_player[:id],
      round: (current_round + 1).floor
    )

    broadcast_update target: "container_game_#{self.id}", partial: 'games/turn', locals: { game: self, turn: turn }
  end

  def end_turn!
    last_turn = self.current_turn
    last_turn.end_turn!

    if last_player[:team] == :mad
      self.mad_score += last_turn.total_score
    else
      self.glad_score += last_turn.total_score
    end
    self.save

    if current_round >= self.rounds
      self.finished!
      broadcast_update target: "container_game_#{self.id}", partial: 'games/end', locals: { game: self }
    else
      self.ready!
      broadcast_update target: "container_game_#{self.id}", partial: 'games/ready', locals: { game: self }
    end
  end

  def current_turn
    self.turns.active.last
  end

  def next_players
    last_turn = self.turns.last
    last_player_id = last_turn&.player_id

    if last_player_id
      last_player_index = self.players.index { |player| player[:id] == last_player_id }
      current_player = self.players[(last_player_index + 1) % self.players.count]
      judge_player = self.players[last_player_index]
    else
      # For the first round
      current_player = self.players.first
      judge_player = self.players.last
    end

    [current_player, judge_player]
  end

  def last_player
    self.players.find { |player| player[:id] == self.turns.last.player_id }
  end

  private

  def current_round
    (self.turns.count.to_f / self.players.count.to_f)
  end

  def generate_code
    code = random_four_letters
    while Game.exists?(code: code)
      code = random_four_letters
    end

    self.code = code
  end

  def random_four_letters
    (0...4).map { ('A'..'Z').to_a[rand(26)] }.join
  end

  def test_game?
    self.code.each_byte.all? { |byte| byte == self.code[0].ord }
  end
end
