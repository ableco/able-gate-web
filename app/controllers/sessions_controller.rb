class SessionsController < ApplicationController
  def create
    user = User.where(email: auth['info']['email'], admin: true).first

    if user.present?
      session[:user_id] = user.id
      redirect_to admin_users_path
    else
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  private

  def auth
    request.env['omniauth.auth']
  end
end
