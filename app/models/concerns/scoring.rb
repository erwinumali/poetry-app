module Scoring
  extend ActiveSupport::Concern

  included do
    def score(word)
      return if self.expired?

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
      return if self.expired?

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

    def update_total_score(type)
      sub_turn = self.current_sub_turn
      return unless sub_turn

      if type == 'bonk'
        self.total_score -= 1
        sub_turn.update(score: -1, skip_type: :bonk)
      elsif type == 'end_turn'
        self.total_score += sub_turn.score
      else
        # Skip (-1)
        if sub_turn.score == 0
          self.total_score -= 1
          sub_turn.update(score: -1, skip_type: :skip)
        # Pass
        else
          self.total_score += sub_turn.score

          if sub_turn.score == 1
            self.easy_count += 1
          elsif sub_turn.score == 3
            self.hard_count += 1
          else
            self.easy_count += 1
            self.hard_count += 1
          end
        end
      end

      self.save
    end

    def broadcast_word(sub_turn, word, difficulty, scored)
      [:current, :judge].each do |player_type|
        broadcast_update_to "turn_#{self.id}_#{player_type}",
          target: "#{difficulty}_sub_turn_#{sub_turn.id}",
          partial: 'turns/word', locals: { word: word, difficulty: difficulty, scored: scored, unclickable: player_type == :judge }
      end
    end
  end
end
