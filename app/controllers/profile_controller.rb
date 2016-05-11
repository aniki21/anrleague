class ProfileController < ApplicationController
  before_filter :require_login, except: [:new,:create,:show]

  # GET /register
  def new
    @user = User.new
    @page_title = "User registration"
  end

  # POST /register
  def create
    @user = User.new(registration_params)
    if valid_recaptcha?
      if @user.save
        flash[:success] = "Your account has been created"
        UserMailer.confirm_register(@user).deliver_now!
        redirect_to login_path(path:params[:path]) and return
      end
    else
      flash.now[:error] = recaptcha_response[:"error-codes"].to_sentence rescue recaptcha_response.to_json
    end
    @page_title = "User registration"
    render action: :new and return
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

    @page_title = @own_profile ? "My profile" : "View profile"
  end

  # GET /profile/edit
  def edit
    @user = current_user
  end

  # POST /profile
  def update
    @user = current_user

    new_email = params[:email]
    old_email = @user.email

    @user.attributes = profile_params

    if @user.save

      unless new_email == old_email
        UserMailer.email_updated(@user,old_email).deliver_now!
      end

      flash[:success] = "Profile updated"
      redirect_to my_profile_path and return
    else
      render action: :edit and return
    end
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
  def registration_params
    params.require(:user).permit(:email,:password,:password_confirmation,:display_name,:jinteki_username)
  end

  def profile_params
    params.require(:user).permit(:email,:display_name,:jinteki_username)
  end

  def password_params
    params.require(:user).permit(:password,:password_confirmation)
  end

end
