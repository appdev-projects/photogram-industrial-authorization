class UsersController < ApplicationController
  before_action :set_user, only: %i[ show liked feed discover ]

  before_action :is_an_authenticated_user, only: [ :feed, :discover ]



  def index
    @users = @q.result
  end

  def show
   true
  end

  def liked
    true
  end
  def feed
    true
  end


  private

    def set_user
      if params[:username]
        @user = User.find_by!(username: params.fetch(:username))
      else
        @user = current_user
      end
    end

    def is_an_authenticated_user
      # Ensure the user is authenticated and can view the profile
      if current_user != @user
        redirect_back(fallback_location: root_url, alert: "You're not authorized for that.")
      end
    end
end
