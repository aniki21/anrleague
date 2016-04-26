class LeaguesController < ApplicationController

  def show
    @league = Liga.find_by_id(params[:id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to root_path and return
    end
  end

  def new
    @league = Liga.new
  end

  def create
    @league = Liga.new(liga_params)
    @league.owner_id = current_user.id
    if @league.save
      flash[:success] = "League created"
      redirect_to league_path(@league.id,@league.display_name.parameterize) and return
    else
      render json: { model: params[:liga], errors: @league.errors.full_messages } and return
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def liga_params
    params.require(:liga).permit(:display_name,:location_type,:online_location,:latitude,:longitude)
  end
end
