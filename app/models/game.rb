class Game < ApplicationRecord
  serialize :players

  enum :state, { waiting: 0, ready: 1, player_turn: 2, player_ready: 3, finished: 4}, default: :waiting

  before_create do
    code = generate_code
    while Game.exists?(code: code)
      code = generate_code
    end

    self.code = code
  end

  def add_player(id, name)
    self.players ||= []
    self.players << { id: id, name: name, score: 0 } unless self.players.any? { |player| player[:id] == id }
    save

    broadcast_updated_players
  end

  def remove_player(id)
    new_players = self.players.reject { |player| player[:id] == id }
    self.players = new_players
    save

    broadcast_updated_players
  end

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
    self.player_turn!

    self.current_player = ''
    self.current_round = 1

    GamesChannel.broadcast_to(self.current_player)
  end

  private

  def broadcast_updated_players
    broadcast_update target: "players_game_#{self.id}", partial: 'games/players', locals: { game: self, players: self.players }
  end

  def generate_code
    (0...4).map { ('A'..'Z').to_a[rand(26)] }.join
  end
end
