class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  def require_login
    unless logged_in?
      redirect_to login_path(path: request.path) and return
    end
  end

  def page
    return (params[:page].to_i == 0) ? 1 : params[:page].to_i
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
end
