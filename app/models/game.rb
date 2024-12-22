class Game < ApplicationRecord
  include Lobby

  has_many :turns

  serialize :players

  enum :state, { waiting: 0, ready: 1, player_turn: 2, player_ready: 3, finished: 4}, default: :waiting

  before_create :generate_code, if: -> { code.nil? }

  validates :code, presence: true, uniqueness: true 

  def prepare!
    shuffled_players = self.players.shuffle
    shuffled_players = shuffled_players.in_groups(2)

    shuffled_players[0].each { |player| player[:team] = :mad }
    shuffled_players[1].each { |player| player[:team] = :glad }

    final_players = (self.players.count / 2).times.map do |i|
      [shuffled_players[0][i], shuffled_players[1][i]]
    end.flatten

    self.players = final_players
    save

    self.ready!

    broadcast_update target: "container_game_#{self.id}", partial: 'games/ready', locals: { game: self }
  end

  def start_game!
    create_turn!
  end

  def create_turn!
    if current_round > self.rounds || !self.current_turn.expired?
      return
    end

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
    if last_player[:team] == :mad
      self.mad_score += self.current_turn.total_score
    else
      self.glad_score += self.current_turn.total_score
    end
    self.save
    self.current_turn.end_turn!

    if current_round >= self.rounds
      self.finished!
      broadcast_update target: "container_game_#{self.id}", partial: 'games/end', locals: { game: self }
    else
      self.player_ready!
      broadcast_update target: "container_game_#{self.id}", partial: 'games/player_ready', locals: { game: self }
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
end
