class GamesController < ApplicationController

  # GET /leagues/:league_id/games
  def index
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

    @season = Season.find_by_id(params[:season_id])
    if @season.blank?
      flash[:error] = "The requested season could not be found"
      redirect_to league_path(@league.id,@league.slug)
    end

    if logged_in? && current_user.member_of?(@league) && params[:all] != "true"
      @games = Game.for_player(current_user.id,@season.id)
      @title = "My games"
    else
      @games = Game.where(season_id: @season.id)
      @title = "All games"
    end

    if params[:filter] == "unplayed"
      @games = @games.unplayed
      @title += " (upcoming)"
    end
  end

  # GET /leagues/:league_id/games/:id
  def show
  end

  # GET /leagues/:league_id/games/:id/edit
  def edit
    @game = Game.where(id: params[:id], league_id: params[:league_id]).first

    unless @game.blank?
      if @game.has_player?(current_user.id)
        @runners = Identity.runner.order(display_name: :asc).map{|r| [r.display_name,r.id ] }
        @corps = Identity.corp.order(display_name: :asc).map{|c| [c.display_name,c.id ] }
        @results = Result.order("lower(display_name) ASC").map{|r| [r.display_name,r.id] }
      else
        flash[:error] = "You don't have permission to do that"
        redirect_to league_path(@game.league_id) and return
      end
    else
      flash[:error] = "The requested game could not be found in the specified league"
      redirect_to leagues_path and return
    end
    render layout: "iframe"
  end

  def update
    @game = Game.where(id: params[:id], league_id: params[:league_id]).first
    unless @game.blank?
      if @game.update_attributes(game_params)
        @game.season.update_table!
        flash[:success] = "Game saved"
        render layout: "iframe" and return
      else
        flash.now[:error] = @game.errors.full_messages.to_sentence
        render action: :edit and return
      end
    else
      flash[:error] = "The requested game could not be found"
      redirect_to league_path(@game.league) and return
    end
  end

  private
  def game_params
    params.require(:game).permit(:runner_identity_id, :runner_agenda_points, :corp_identity_id, :corp_agenda_points, :result_id)
  end

end
