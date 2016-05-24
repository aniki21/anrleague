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
  scope :cancelled, ->() { where(result_id:0) }

  scope :for_player, ->(player_id) { where("runner_player_id = ? OR corp_player_id = ?",player_id, player_id) }
  scope :for_season, ->(season_id) { where(season_id: season_id) }
  scope :for_player_season, ->(player_id,season_id) { for_player(player_id).for_season(season_id) }
  scope :player_season_wins, ->(player_id,season_id) { where(season_id: season_id).where("(runner_player_id = ? AND result_id IN (?)) OR (corp_player_id = ? AND result_id IN (?))",player_id,Result.runner_win.map(&:id),player_id,Result.corp_win.map(&:id)) }
  scope :player_season_losses, ->(player_id,season_id) { where(season_id: season_id).where("(runner_player_id = ? AND result_id IN (?)) OR (corp_player_id = ? AND result_id IN (?))",player_id,Result.corp_win.map(&:id),player_id,Result.runner_win.map(&:id)) }
  scope :player_season_draws, ->(player_id,season_id) { for_player(player_id,season_id).where(result_id: Result.where(winning_side:"draw")).map(&:id) }

  # Methods

  def corp_win?
    return false if self.result.blank?
    return self.result.corp_win?
  end
  
  def runner_win?
    return false if self.result.blank?
    return self.result.runner_win?
  end

  def draw?
    return false if self.result.blank?
    return self.result.draw?
  end

  def has_player?(user)
    return false if user.blank?
    return (self.runner_player_id == user.id || self.corp_player_id == user.id)
  end

  def unplayed?
    self.result_id.nil?
  end

  def cancelled?
    self.result_id == 0
  end

  def cancel
    self.result_id = 0
  end

  def cancel!
    self.cancel
    self.save(validate: false)
  end

  def result_for_player(user)
    return nil if self.result_id.blank? || ![self.runner_player_id,self.corp_player_id].include?(user.id)
    return (self.winning_player_id == user.id) ? "Win" : (self.winning_player_id.blank? ? "Draw" : "Loss")
  end

  def players
    User.where(id: [self.corp_player_id,self.runner_player_id])
  end

  def user_can_update?(user)
    return false if user.blank?
    return self.players.include?(user) if self.result_id.blank?
    return self.league.officers.include?(user)
    return false
  end

  private
  def set_winning_player_id
    unless self.result.blank?
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
end
