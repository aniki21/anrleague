class HomeController < ApplicationController

  # GET /
  # Homepage
  def index
    leagues = Liga.where(table_privacy: "public").map(&:id)
    @recent = Season.where(league_id:leagues).active.order(activated_at: :desc)

    if logged_in?
      season_ids = current_user.games.unplayed.map(&:season_id)
      @seasons_with_games = Season.where(id: season_ids).active
    end
  end

  # GET /about
  def about
  end

  # GET /blank
  def blank
    render text: "" and return
  end

end
