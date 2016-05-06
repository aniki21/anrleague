class HomeController < ApplicationController

  # GET /
  # Homepage
  def index
    if logged_in?
      # load leagues and upcoming matches?
    end
  end

  def blank
    render text: "" and return
  end

end
