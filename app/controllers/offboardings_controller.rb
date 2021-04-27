class OffboardingsController < ApplicationController
  def create
    user = User.find(params['format'])
    user.offboard!

    flash.notice = "#{user.full_name} has been offboarded!"

    redirect_to admin_users_path
  end

  def update
    user = User.find(params['id'])
    user.offboard_from_project!
    redirect_to admin_user_path(user)
  end
end
