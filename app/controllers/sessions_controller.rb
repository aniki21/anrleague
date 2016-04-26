class SessionsController < ApplicationController

  # GET /login
  def new
    # Don't need to do anything here
  end

  # POST /login
  def create
    redir_path = params[:path].blank? ? profile_path : params[:path]
    if login(params[:email],params[:password],params[:remember_me])
      flash[:success] = "Login successful"
      redirect_to redir_path and return
    else
      flash[:error] = "Unable to log in. Check your username and password and try again."
      redirect_to login_path and return
    end

  end

  # GET /logout
  def destroy
    logout
    flash[:success] = "Logged out successfully"
    redirect_to root_path and return
  end
end
