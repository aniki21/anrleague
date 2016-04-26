class UsersController < ApplicationController

  # GET /users
  def index
  end

  # GET /register
  def new
    @user = User.new
  end

  # POST /register
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Your account has been created"
      redirect_to login_path and return
    else
      render action: :new and return
    end
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

  private
  def user_params
    params.require(:user).permit(:email,:password,:password_confirmation,:display_name,:jinteki_username)
  end

end
