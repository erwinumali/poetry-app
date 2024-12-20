module Scoring
  extend ActiveSupport::Concern

  included do
    def score(word)
      sub_turn = self.current_sub_turn

      # Score only if the word isn't scored yet
      if sub_turn.easy_word == word
        sub_turn.score += 1 if sub_turn.score == 0 || sub_turn.score == 3
        sub_turn.save

        broadcast_word(sub_turn, word, :easy, true)
      elsif sub_turn.hard_word == word
        sub_turn.score += 3 if sub_turn.score == 0 || sub_turn.score == 1
        sub_turn.save

        broadcast_word(sub_turn, word, :hard, true)
      end
    end

    def unscore(word)
      sub_turn = self.current_sub_turn

      if sub_turn.easy_word == word
        sub_turn.score -= 1 if sub_turn.score == 1 || sub_turn.score == 4
        sub_turn.save

        broadcast_word(sub_turn, word, :easy, false)
      elsif sub_turn.hard_word == word
        sub_turn.score -= 3 if sub_turn.score == 3 || sub_turn.score == 4
        sub_turn.save

        broadcast_word(sub_turn, word, :hard, false)
      end
    end

    private

    def broadcast_word(sub_turn, word, difficulty, scored)
      broadcast_update_to self.game,
        target: "#{difficulty}_sub_turn_#{sub_turn.id}",
        partial: 'turns/word', locals: { word: word, difficulty: difficulty, scored: scored }
    end
  end
end
