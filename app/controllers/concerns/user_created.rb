module UserCreated
  extend ActiveSupport::Concern

  included do
    before_action :user_created?

    def user_created?
      @user_id = session[:user_id]
      @user_name = session[:user_name]

      unless @user_id && @user_name
        if action_name == 'show' && controller_name == 'games' && params[:code]
          redirect_to new_user_path(referrer: params[:code])
        else
          redirect_to new_user_path
        end
      end
    end
  end
end
