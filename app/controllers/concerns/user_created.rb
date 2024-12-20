module UserCreated
  extend ActiveSupport::Concern

  included do
    before_action :user_created?

    def user_created?
      @user_id = session[:user_id]
      @user_name = session[:user_name]

      redirect_to new_user_path unless @user_id && @user_name
    end
  end
end
