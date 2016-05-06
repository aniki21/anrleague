class Admin::UsersController < AdminController

  # GET /admin/users
  def index
  end

  # GET /admin/users/search
  def search
    render text: "Coming soon (#{params[:q]})"
  end

end
