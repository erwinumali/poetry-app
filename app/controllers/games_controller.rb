class GamesController < ApplicationController
  before_action :user_created?
  before_action :get_game, except: [:new, :create]
  before_action :ensure_host, only: [:remove_player, :ready, :start, :stop]

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
      handle_game_state
    end
  end

  def remove_player
    @game.remove_player(params[:player_id])

    respond_to do |format|
      format.html { redirect_to game_path(code: @game.code) }
    end
  end

  def ready
    if @game.players.count % 2 != 0
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to game_path(code: @game.code)}
      end
    else
      @game.prepare!

      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { render :ready }
      end
    end
  end

  def start
    @game.start_game!

    redirect_to @game
  end

  def stop
    @game.finished!
    redirect_to @game
  end

  private

  def ensure_host
    redirect_to root_path unless @game.host == @user_id
  end

  def handle_game_state
    if @game.players.any? { |player| player[:id] == @user_id }
      case @game.state.to_sym
      when :waiting
        render :show
      when :ready
        render :ready
      when :player_turn
        render :turn
      else
        puts 'Invalid game!'
        redirect_to new_game_path
      end
    else
      case @game.state.to_sym
      when :waiting
        @game.add_player(@user_id, @user_name)
      else
        puts 'Game has already started!'
        redirect_to new_game_path
      end
    end
  end

  def get_game
    @game = Game.find_by_code(params[:code])
    @turn = @game&.current_turn
  end

  def user_created?
    @user_id = session[:user_id]
    @user_name = session[:user_name]

    redirect_to new_user_path unless @user_id && @user_name
  end
end
