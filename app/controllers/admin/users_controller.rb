class Admin::UsersController < AdminController
  before_filter :fetch_user, except: [:index]

  # GET /admin/users
  def index
    @users = User.all

    @users = @users.order(created_at: :desc).paginate(page: page)
  end

  # GET /admin/users/:id/edit
  def edit
  end

  # POST /admin/users/:id
  def update
  end

  # GET /admin/users/:id/ban
  def ban
    if @user.may_ban?
      @user.ban!(:banned,params[:ban_expires_at])
      flash[:success] = "The user has been banned"
    else
      flash[:error] = "The user could not be banned"
    end
    redirect_to edit_admin_user_path(@user.id)
  end

  # GET /admin/users/:id/unban
  def unban
    if @user.may_unban?
      @user.unban!
      flash[:success] = "The user has been unbanned"
    else
      flash[:error] = "The user could not be unbanned"
    end
    redirect_to edit_admin_user_path(@user.id)
  end

  # DELETE /admin/users/:id
  def destroy
    @user.destroy
    flash[:success] = "The requested user account has been deleted"
    redirect_to admin_users_path and return
  end

  private
  def fetch_user
    @user = User.find_by_id(params[:id])
    if @user.blank?
      flash[:error] = "The requested user could not be found"
      redirect_to admin_users_path and return
    end
  end
end
