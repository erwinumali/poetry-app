module Lobby
  extend ActiveSupport::Concern

  included do
    def add_player(id, name)
      self.players ||= []
      unless self.players.any? { |player| player[:id] == id }
        self.players << { id: id, name: name, score: 0, easy_count: 0, hard_count: 0 }
      end

      self.host = id if self.players.count == 1

      save

      broadcast_updated_players
    end

    def remove_player(id)
      new_players = self.players.reject { |player| player[:id] == id }
      self.players = new_players
      save

      broadcast_updated_players
      broadcast_update_to "game_#{self.id}_user_#{id}", target: "redirect_game_#{self.id}", partial: 'lobby/redirect'
    end

    private

    def shuffle_players!
      shuffled_players = self.players
      shuffled_players = shuffled_players.shuffle unless self.test_game?
      shuffled_players = shuffled_players.in_groups(2)

      shuffled_players[0].each { |player| player[:team] = :mad }
      shuffled_players[1].each { |player| player[:team] = :glad }

      final_players = (self.players.count / 2).times.map do |i|
        [shuffled_players[0][i], shuffled_players[1][i]]
      end.flatten

      self.players = final_players
      save
    end

    def broadcast_updated_players
      broadcast_update target: "players_game_#{self.id}", partial: 'lobby/players', locals: { game: self, players: self.players }
    end
  end
end
