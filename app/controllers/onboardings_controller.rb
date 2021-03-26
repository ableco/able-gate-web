class OnboardingsController < ApplicationController
  def create
    user = User.find(params['format'])
    user.onboard!

    flash.notice = "#{user.full_name} has been onboarded!"

    redirect_to admin_users_path
  end
end
