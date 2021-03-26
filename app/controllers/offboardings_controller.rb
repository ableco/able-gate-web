class OffboardingsController < ApplicationController
  def create
    user = User.find(params['format'])
    user.offboard!

    flash.notice = "#{user.full_name} has been offboarded!"

    redirect_to admin_users_path
  end
end
