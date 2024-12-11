class Game < ApplicationRecord
  serialize :players

  enum :state, waiting: 0, ready: 1, playing: 2, finished: 3

  # after_update_commit do
  #   broadcast_replace_to self, :players, partial: "games/players", locals: { game: self, players: self.players }
  # end

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

    realtime_replace
  end

  def remove_player(id)
    new_players = self.players.reject { |player| player[:id] == id }
    self.players = new_players
    save

    realtime_replace
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
  end

  private

  def realtime_replace
    broadcast_replace target: "players_game_#{self.id}", partial: "games/players", locals: { game: self, players: self.players }
  end

  def generate_code
    (0...4).map { ('A'..'Z').to_a[rand(26)] }.join
  end
end
