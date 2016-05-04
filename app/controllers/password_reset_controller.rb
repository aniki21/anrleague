class PasswordResetController < ApplicationController

  # GET /password_reset/new
  def new
    # show form
  end

  # POST /password_reset
  def create
    @user = User.find_by_email(params[:email])
    if @user
      flash[:success] = "Instructions have been sent to your email"
      @user.generate_reset_password_token!
      UserMailer.reset_password_email(@user).deliver_now!
      redirect_to login_path and return
    else
      flash[:error] = "A user could not be found with that email address"
      redirect_to password_resets_path and return
    end
  end

  # GET /password_reset/:id
  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated and return
    end
  end

  # POST /password_reset/:id
  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated and return
    end

    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password!(params[:user][:password])
      UserMailer.password_updated(@user).deliver_now!
      flash[:success] = "Your password has been updated successfully"
      redirect_to login_path and return
    else
      render :action => "edit"
    end
  end

end
