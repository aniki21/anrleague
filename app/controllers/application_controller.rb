class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :my_leagues

  private
  def require_login
    unless logged_in?
      flash[:warning] = "You need to be logged in to do that"
      redirect_to login_path(path: request.path) and return
    end
  end

  # Generic method to calculate page number for pagination
  def page
    _page = params[:page].to_i
    return (_page == 0) ? 1 : _page
  end

  # Generate games for all approved players in the league
  def generate_games(season)
    unless season.blank?
      player_ids = season.approved_players.map(&:id).uniq
      player_ids.each do |player_id|
        opponent_ids = player_ids - [ player_id ]
        opponent_ids.each do |opponent_id|
          # Runner
          runner_game = {
            league_id: season.league_id,
            season_id: season.id,
            runner_player_id: player_id,
            corp_player_id: opponent_id
          }
          Game.create(runner_game) unless Game.where(runner_game).any?

          # Corp
          corp_game = {
            league_id: season.league_id,
            season_id: season.id,
            runner_player_id: opponent_id,
            corp_player_id: player_id
          }
          Game.create(corp_game) unless Game.where(corp_game).any?
        end
      end

      season.update_table!
    end
  end

  def valid_recaptcha?
    recaptcha_response = Recaptcha.validate_response(params[:"g-recaptcha-response"])
    if recaptcha_response["success"].to_s == "true"
      return true
    else
      flash.now[:error] = "Invalid reCAPTCHA"
      return false
    end
  end

  def my_leagues
    if logged_in?
      @my_leagues = current_user.liga_users.approved.map(&:league)
    end
  end
end
