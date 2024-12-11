class Game < ApplicationRecord
  serialize :players

  enum :state, waiting: 0, playing: 1, finished: 2

  after_update_commit do
    ActionCable.server.broadcast 'game_channel', { game: self }
  end

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
  end

  private

  def generate_code
    (0...4).map { ('A'..'Z').to_a[rand(26)] }.join
  end
end
