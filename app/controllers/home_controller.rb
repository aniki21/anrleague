class HomeController < ApplicationController

  # GET /
  # Homepage
  def index
    leagues = Liga.where(table_privacy: "public").map(&:id)
    @recent = Season.where(league_id:leagues).active.order(activated_at: :desc)

    if logged_in?
      # load my leagues and upcoming matches?
    end

    @api_request = HttpsRequest.get('https://netrunnerdb.com/api/card/05038') rescue "error"
  end

  # GET /about
  def about
  end

  # GET /blank
  def blank
    render text: "" and return
  end

end
