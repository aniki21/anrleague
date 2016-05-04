class ProfileController < ApplicationController
  before_filter :require_login, except: [:new,:create,:show]

  # GET /register
  def new
    @user = User.new
  end

  # POST /register
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Your account has been created"
      UserMailer.confirm_register(@user).deliver_now!
      redirect_to login_path and return
    else
      render action: :new and return
    end
  end

  # GET /profile/:id/:username
  # GET /profile
  def show
    unless params[:id].blank?
      @user = User.find_by_id(params[:id])
    else
      if logged_in?
        @user = current_user
      else
        require_login
      end
    end
    
    if @user.blank?
      flash[:error] = "User not found"
      redirect_to root_path and return
    end

    @own_profile = @user.id == current_user.id
  end

  # GET /profile/edit
  def edit
    @user = current_user
  end

  # POST /profile
  def update
  end

  # POST /profile/password
  def update_password
    if current_user.valid_password?(params[:current_password])
      current_user.attributes = {
        password: params[:new_password],
        password_confirmation: params[:new_password_confirmation]
      }
      if current_user.save
        UserMailer.password_updated(current_user).deliver_now!
        logout
        flash[:success] = "Your password has been updated - please log in again"
        redirect_to login_path and return
      else
        flash[:error] = current_user.errors.full_messages.to_sentence
      end
    else
      flash[:error] = "The password you entered was incorrect"
    end
    redirect_to edit_profile_path and return
  end

  private
  def user_params
    params.require(:user).permit(:email,:password,:password_confirmation,:display_name,:jinteki_username)
  end

end
