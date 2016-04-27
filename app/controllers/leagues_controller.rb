class LeaguesController < ApplicationController

  def index
    case params[:t]
    when "online"
      @leagues = Liga.online
    when "offline"
      @leagues = Liga.offline
    else
      @leagues = Liga.all
    end
  end

  def show
    @league = Liga.find_by_id(params[:id])
    if params[:slug].blank?
      redirect_to show_league_path(@league.id,@league.slug) and return
    end
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to root_path and return
    end

    @season = @league.current_season
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
    @league = Liga.find_by_id(params[:id])

    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    unless current_user.id == @league.owner_id
      flash[:error] = "You don't have permission to do that"
      redirect_to league_path(@league.id,@league.slug)
    end
  end

  def update
    @league = Liga.find_by_id(params[:id])

    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    unless current_user.id == @league.owner_id
      flash[:error] = "You don't have permission to do that"
      redirect_to league_path(@league.id,@league.slug)
    end

    if @league.update_attributes(liga_params)
      flash[:success] = "League updated"
      redirect_to show_league_path(@league.id,@league.slug)
    end
  end

  def destroy
  end

  private
  def liga_params
    params.require(:liga).permit(:display_name,:location_type,:online_location,:latitude,:longitude,:description_markdown)
  end
end
