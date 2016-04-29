class AdminController < ApplicationController
  before_filter :require_login, :user_is_admin

  # GET /admin
  def index
  end

  private
  def user_is_admin
    unless current_user.admin?
      flash[:error] = "You don't have access to that"
      redirect_to root_path and return
    end
  end
end
