class GamesController < ApplicationController

  # GET /leagues/:league_id/games
  def index
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
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
  end

end
