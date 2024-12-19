class Game < ApplicationRecord
  include Lobby

  has_many :turns

  serialize :players

  enum :state, { waiting: 0, ready: 1, player_turn: 2, player_ready: 3, finished: 4}, default: :waiting

  before_create :generate_code

  def prepare!
    shuffled_players = self.players.shuffle.in_groups(2)
    shuffled_players[0].each { |player| player[:team] = 1 }
    shuffled_players[1].each { |player| player[:team] = 2 }

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
    return if current_round > self.rounds

    self.player_turn!

    last_active_turn = self.current_turn
    last_active_player_id = last_active_turn&.player_id

    if last_active_player_id
      last_active_turn.end_turn!

      last_active_player_index = self.players.index { |player| player[:id] == last_active_player_id }
      current_player = self.players[(last_active_player_index + 1) % self.players.count]
      judge_player = self.players[last_active_player_index]
    else
      # For the first round
      current_player = self.players.first
      judge_player = self.players.last
    end

    self.turns.create(
      player_id: current_player[:id],
      judge_id: judge_player[:id],
      round: current_round.floor
    )

    broadcast_update target: "container_game_#{self.id}", partial: 'games/turn', locals: { game: self, player: current_player }
  end

  def current_turn
    self.turns.active.last
  end

  private

  def current_round
    (self.turns.count.to_f / self.players.count.to_f) + 1
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
