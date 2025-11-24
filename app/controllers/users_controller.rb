class UsersController < ApplicationController
  before_action :user_created?, only: [:new, :create]

  def new; end

  def create
    if params[:name].present?
      session[:user_id] = SecureRandom.uuid
      session[:user_name] = params[:name]

      if params[:referrer]
        redirect_to game_path(code: params[:referrer])
      else
        redirect_to new_game_path
      end
    else
      render :error
    end
  end

  def destroy
    reset_session
    redirect_to new_user_path
  end

  private

  def user_created?
    if session[:user_id] && session[:user_name]
      redirect_to new_game_path
    end
  end
end
