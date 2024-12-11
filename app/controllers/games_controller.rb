class GamesController < ApplicationController
  before_action :user_created?
  before_action :get_game, only: [:show, :start, :stop]

  def new
  end

  def create
    @game = Game.create(host: session[:user_id])
    @game.players = []
    @game.players << { id: session[:user_id], name: session[:user_name], score: 0}
    @game.save

    redirect_to game_path(code: @game.code)
  end

  def show
    if @game.nil?
      redirect_to new_game_path
    else
      @game.add_player(@user_id, @user_name)
      @game
    end
  end

  def start
    @game.playing!
    redirect_to @game
  end

  def stop
    @game.finished!
    redirect_to @game
  end

  private

  def get_game
    @game = Game.find_by_code(params[:code])
  end

  def user_created?
    @user_id = session[:user_id]
    @user_name = session[:user_name]

    redirect_to new_user_path unless @user_id && @user_name
  end
end
