class GamesController < ApplicationController

  # GET /leagues/:league_id/games
  def index
    @league = Liga.find_by_id(params[:league_id])
    if @league.blank?
      flash[:error] = "The requested league could not be found"
      redirect_to leagues_path and return
    end

  end

end
