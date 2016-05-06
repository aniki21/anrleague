class SeasonsController < ApplicationController
  before_filter :require_login, except: [:show]
  before_filter :fetch_league

  def index
    @seasons = @league.seasons
  end

  def show
    @season = @league.seasons.find_by_id(params[:id])
    if @season.blank?
      flash[:error] = "The requested season could not be found"
      redirect_to league_path(@league.id) and return
    end
  end

  # GET /league/:league_id/seasons/new
  def new
    @season = Season.new(league_id: params[:league_id])
  end

  # POST /league/:league_id/seasons
  def create
    @season = Season.new(season_params) 
    if @season.save
      flash[:success] = "The new season has been created"
    else
      flash[:error] = @season.errors.full_messages.to_sentence
    end
    redirect_to edit_league_path(@season.league_id) and return
  end

  def edit
  end

  def update
  end
  
  # DELETE /leagues/:league_id/seasons/:id
  def destroy
    league = Liga.find_by_id(params[:league_id])
    unless league.blank?
      season = Season.where(league_id:params[:league_id],id:params[:id]).first
      unless season.blank?
        flash[:success] = "Season deleted"
        season.destroy
      else
        flash[:error] = "The requested season could not be found"
      end
      redirect_to edit_league_path(league.id) and return
    else
      flash[:error] = "The requested league could not be found"
    end
    redirect_to leagues_path and return
  end

  # GET /leagues/:league_id/seasons/:id/activate
  def activate
    season = Season.find_by_id(params[:id])
    unless season.blank?
      if season.may_activate?
        season.activate!
        generate_games(season)
        flash[:success] = "Season activated!"
      else
        flash[:error] = "Season could not be activated"
      end
    else
      flash[:error] = "The requested season could not be found"
    end
    redirect_to edit_league_path(params[:league_id])
  end

  def deactivate
  end

  private
  def fetch_league
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end
  end

  def season_params
    params.require(:season).permit(:display_name, :league_id)
  end

end
