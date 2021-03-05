class HomeController < ApplicationController
  layout false

  def index
    redirect_to admin_users_path if logged_in?
  end
end
