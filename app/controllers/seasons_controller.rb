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
    @season = Season.new(league_id: params[:league_id], league_table: "[]")

    if @season.save
      generate_games(@season)
    else
      flash.now[:errors] = @season.errors.full_messages.to_sentence
      render action: :new
    end
  end

  def edit
  end

  def update
  end
  
  def destroy
  end

  def activate
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
    params.require(:season).permit(:display_name)
  end

  def generate_games(season)
    player_ids = season.players.map(&:id)
    player_ids.each do |player_id|
      opponent_ids = player_ids - [player_id]
      opponent_ids.each do |opponent_id|
        # create two games - one as runner, one as corp
        Game.create(league_id: season.league_id, season_id: season.id, runner_player_id: player_id, corp_player_id: opponent_id)
        Game.create(league_id: season.league_id, season_id: season.id, runner_player_id: opponent_id, corp_player_id: player_id)
      end
    end
  end
end
