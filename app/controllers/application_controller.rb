class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  def require_login
    unless logged_in?
      redirect_to login_path(path: request.path) and return
    end
  end

  def page
    return (params[:page].to_i == 0) ? 1 : params[:page].to_i
  end
end
