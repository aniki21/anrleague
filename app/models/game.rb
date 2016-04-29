class Game < ActiveRecord::Base

  # Associations
  belongs_to :league, class_name: "Liga", foreign_key: "league_id"
  belongs_to :season
  belongs_to :runner_player, class_name: "User"
  belongs_to :runner_identity, class_name: "Identity"
  belongs_to :corp_player, class_name: "User"
  belongs_to :corp_identity, class_name: "Identity"

  # Validations
  validates :league_id, presence: true
  validates :season_id, presence: true
  validates :runner_player_id, presence: true
  validates :corp_player_id, presence: true

  # Scopes
  scope :unplayed, ->() { where(result: 0) }
  scope :runner_win, ->() { where(result:[1,2]) }
  scope :corp_win, ->() { where(result:[3,4]) }

  scope :for_player, ->(player_id,season_id) { where("runner_player_id = ? OR corp_player_id = ?",player_id, player_id) }
  scope :player_season_wins, ->(player_id,season_id) { where(season_id: season_id).where("(runner_player_id = ? AND result_id IN (?)) OR (corp_player_id = ? AND result_id IN (?))",player_id,Result.runner_win.map(&:id),player_id,Result.corp_win.map(&:id)) }
  scope :player_season_losses, ->(player_id,season_id) { where(season_id: season_id).where("(runner_player_id = ? AND result_id IN (?)) OR (corp_player_id = ? AND result_id IN (?))",player_id,Result.corp_win.map(&:id),player_id,Result.runner_win.map(&:id)) }
  scope :player_season_draws, ->(player_id,season_id) { for_player(player_id,season_id).where(result_id: Result.where(winning_side:"draw")).map(&:id) }

  # Valid results
  # enum result: [
  #   :unplayed,        # 0 - no result
  #   :runner_points,   # 1 - Runner wins on points
  #   :runner_rd,       # 2 - Runner wins by milling Corp R&D
  #   :corp_points,     # 3 - Corp wins on points
  #   :corp_flatline,   # 4 - Corp wins by flatlining the runner
  #   :draw_time,       # 5 - The game ends due to time (IRL only?)
  #   :runner_conceed,  # 6 - Corp wins by Runner concession
  #   :corp_conceed     # 7 - Runner wins by Corp concession
  # ]

  # Methods
  def has_player?(player_id)
    return (self.runner_player_id == player_id || self.corp_player_id == player_id)
  end
end
