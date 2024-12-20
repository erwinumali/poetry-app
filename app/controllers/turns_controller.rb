class TurnsController < ApplicationController
  include UserCreated

  before_action :get_game
  before_action :get_turn

  def score
    @turn.score(params[:word])
    head :ok
  end

  def unscore
    @turn.unscore(params[:word])
    head :ok
  end

  def skip
    head :ok
  end

  private

  def get_game
    @game = Game.find_by(code: params[:game_code])
  end

  def get_turn
    @turn = @game.turns.find_by(id: params[:id])
  end
end
