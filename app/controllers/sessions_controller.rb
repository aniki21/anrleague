class SessionsController < ApplicationController

  # GET /login
  def new
    if logged_in?
      redirect_to root_path and return
    end
    @user = User.new
  end

  # POST /login
  def create
    redir_path = params[:path].blank? ? profile_path : params[:path]
    if login(params[:email],params[:password],params[:remember_me])
      flash[:success] = "Logged in successfully"
      redirect_to redir_path and return
    else
      flash[:error] = "Unable to log you in. Check your username and password and try again."
      redirect_to login_path and return
    end
  end

  # GET /logout
  def destroy
    redir_path = params[:path].blank? ? root_path : params[:path]
    logout
    flash[:success] = "Logged out successfully"
    redirect_to redir_path and return
  end
end
