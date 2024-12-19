module Lobby
  extend ActiveSupport::Concern

  included do
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

    private

    def broadcast_updated_players
      broadcast_update target: "players_game_#{self.id}", partial: 'games/players', locals: { game: self, players: self.players }
    end
  end
end
