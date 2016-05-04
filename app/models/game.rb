class Game < ActiveRecord::Base
  # Associations
  belongs_to :league, class_name: "Liga", foreign_key: "league_id"
  belongs_to :season
  belongs_to :runner_player, class_name: "User"
  belongs_to :runner_identity, class_name: "Identity"
  belongs_to :corp_player, class_name: "User"
  belongs_to :corp_identity, class_name: "Identity"
  belongs_to :result

  # Validations
  validates :league_id, presence: true
  validates :season_id, presence: true
  validates :runner_player_id, presence: true
  validates :corp_player_id, presence: true

  # Callbacks
  before_save :set_winning_player_id, if: :result_id

  # Scopes
  scope :unplayed, ->() { where(result_id:nil) }
  scope :runner_win, ->() { where(result_id:Result.runner_win.map(&:id)) }
  scope :corp_win, ->() { where(result_id:Result.corp_win.map(&:id)) }
  scope :draw, ->() { where(result_id:Result.draw.map(&:id)) }

  scope :for_player, ->(player_id,season_id) { where("runner_player_id = ? OR corp_player_id = ?",player_id, player_id) }
  scope :player_season_wins, ->(player_id,season_id) { where(season_id: season_id).where("(runner_player_id = ? AND result_id IN (?)) OR (corp_player_id = ? AND result_id IN (?))",player_id,Result.runner_win.map(&:id),player_id,Result.corp_win.map(&:id)) }
  scope :player_season_losses, ->(player_id,season_id) { where(season_id: season_id).where("(runner_player_id = ? AND result_id IN (?)) OR (corp_player_id = ? AND result_id IN (?))",player_id,Result.corp_win.map(&:id),player_id,Result.runner_win.map(&:id)) }
  scope :player_season_draws, ->(player_id,season_id) { for_player(player_id,season_id).where(result_id: Result.where(winning_side:"draw")).map(&:id) }

  # Delegates
  delegate :runner_win?, to: :result
  delegate :corp_win?, to: :result
  delegate :draw?, to: :result
  
  # Methods
  def has_player?(player_id)
    return (self.runner_player_id == player_id || self.corp_player_id == player_id)
  end

  def unplayed?
    self.result.nil?
  end

  def result_for_player(player_id)
    return nil if self.result_id.blank?
    return (self.winning_player_id == player_id) ? "Win" : (self.winning_player_id.blank? ? "Draw" : "Loss")
  end

  private
  def set_winning_player_id
    case self.result.winning_side
    when "runner"
      self.winning_player_id = self.runner_player_id
    when "corp"
      self.winning_player_id = self.corp_player_id
    else
      # do nothing
    end
  end
end
