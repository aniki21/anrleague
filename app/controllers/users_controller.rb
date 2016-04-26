class UsersController < ApplicationController

  # GET /users
  def index
  end

  # GET /register
  def new
  end

  # POST /register
  def create
  end

  # GET /users/:id
  # GET /profile
  def show
    unless params[:id].blank?
      @user = User.find_by_id(params[:id])
    else
      @user = current_user
    end
    
    if @user.blank?
      flash[:error] = "User not found"
      redirect_to root_path and return
    end
  end

  # GET /profile/edit
  def edit
  end

  # POST /profile
  def update
  end

end
