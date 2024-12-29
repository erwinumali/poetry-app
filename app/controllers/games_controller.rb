class GamesController < ApplicationController
  include UserCreated

  before_action :get_game, except: [ :new, :create ]
  before_action :ensure_host, only: [ :remove_player, :ready, :start ]

  def index
    redirect_to new_game_path
  end

  def new
  end

  def create
    @game = Game.create(host: session[:user_id])
    @game.players = []
    @game.players << { id: session[:user_id], name: session[:user_name], score: 0 }
    @game.save

    if @game
      redirect_to game_path(code: @game.code)
    else
      redirect_to new_game_path
    end
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
    if invalid_player_count
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to game_path(code: @game.code) }
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

    respond_to do |format|
      format.turbo_stream { head :ok }
      format.html { redirect_to game_path(code: @game.code) }
    end
  end

  def end_turn
    current_turn = @game.current_turn

    # Ensure judge
    if current_turn.judge_id == @user_id
      # Only end the turn if the turn has expired or
      # the turn has ran out of words
      if current_turn.expired? || (!current_turn.expired? && current_turn.words.count < 2)
        @game.end_turn!

        respond_to do |format|
          format.turbo_stream { head :ok }
          format.json { { status: 200 } }
          format.html { redirect_to game_path(code: @game.code) }
        end
      else
        head :ok
      end
    else
      head :ok
    end
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
        if @game.current_turn.expired? || @game.current_turn.words.count < 2
          @game.end_turn!

          redirect_to game_path(code: @game.code)
        else
          render :turn
        end
      when :finished
        render :end
      else
        puts 'Invalid game!'
        redirect_to new_game_path
      end
    else
      if @game.state.to_sym == :waiting
        @game.add_player(@user_id, @user_name)
      else
        puts 'Game has already started!'
        redirect_to new_game_path
      end
    end
  end

  def get_game
    @game = Game.find_by_code(params[:code])
  end

  def invalid_player_count
    @game.players.count % 2 != 0 ||
      @game.players.count < 2 ||
      @game.players.count > 12
  end
end
