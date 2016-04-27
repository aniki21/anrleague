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
    @game = Game.where(id: params[:game_id], league_id: params[:league_id])

    unless @game.blank?
      if @game.has_player?(current_user.id)
        # we can edit this!
      else
        flash[:error] = "You don't have permission to do that"
      end
    else
      flash[:error] = "The requested game could not be found in the specified league"
    end
  end

end
