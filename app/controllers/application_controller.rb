class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery with: :exception

  def authorize
    redirect_to root_path unless logged_in?
  end

  def logged_in?
    !current_user.nil?
  end
end
