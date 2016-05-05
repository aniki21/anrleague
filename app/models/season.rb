class Season < ActiveRecord::Base
  # Associations
  belongs_to :league, class_name: "Liga"
  has_many :games, dependent: :destroy

  # Validations
  validates :league_id, presence: true
  validates :display_name, presence: true, length: { maximum: 50, message: "cannot be more than 50 characters" }
  validate :display_name_unique_for_league

  # Callbacks
  before_validation :update_table

  # State machine
  include AASM
  aasm do
    state :upcoming, initial: true
    state :active, before_enter: :close_active_seasons
    state :closed

    event :activate do
      transitions from: [:upcoming], to: :active
    end

    event :close do
      transitions from: [:active], to: :closed
    end
  end

  # Methods
  delegate :players , to: :league
  delegate :approved_players, to: :league
  
  def table
    JSON.parse(self.league_table || "[]").map(&:symbolize_keys)
  end

  def update_table
    # Go through all games and build the league table
    # Games are generated in SeasonsController#generate_games

    # { player_id: { name: "name", played: 0, wins: 0, losses: 0, draws: 0, ap: 0, lp: 0 }
    table = {}

    self.games.each do |game|
      runner = game.runner_player
      corp = game.corp_player
      # initialize the players' league rows
      table[:"#{runner.id}"] ||= { name: runner.display_name, played: 0, wins: 0, losses: 0, draws: 0, ap: 0, lp: 0 }
      table[:"#{corp.id}"] ||= { name: corp.display_name, played: 0, wins: 0, losses: 0, draws: 0, ap: 0, lp: 0 }

      # result
      unless game.result_id.blank?
        table[:"#{runner.id}"][:played] += 1
        table[:"#{corp.id}"][:played] += 1
        table[:"#{runner.id}"][:ap] += game.runner_agenda_points
        table[:"#{corp.id}"][:ap] += game.corp_agenda_points

        if game.runner_win?
          # runner win
          table[:"#{runner.id}"][:wins] += 1
          table[:"#{runner.id}"][:lp] += game.league.points_for_win
          table[:"#{corp.id}"][:losses] += 1
          table[:"#{corp.id}"][:lp] += game.league.points_for_loss
        elsif game.corp_win?
          table[:"#{runner.id}"][:losses] += 1
          table[:"#{runner.id}"][:lp] += game.league.points_for_loss
          table[:"#{corp.id}"][:wins] += 1
          table[:"#{corp.id}"][:lp] += game.league.points_for_win
          # corp win
        elsif game.draw?
          # points for everybody!
          table[:"#{runner.id}"][:draws] += 1
          table[:"#{runner.id}"][:lp] += game.league.points_for_draw
          table[:"#{corp.id}"][:draws] += 1
          table[:"#{corp.id}"][:lp] += game.league.points_for_draw
        else
          # nothing?
        end
      else
        # do nothing
      end
    end
    
    table = table.map(&:last)
    table = table.sort do |a,b|
      comp = (b[:lp] <=> a[:lp])
      comp.zero? ? (b[:ap] <=> a[:ap]) : comp
    end

    self.league_table = table.to_json
  end

  def update_table!
    self.update_table
    self.save(validate: false)
  end

  private
  def display_name_unique_for_league
    if self.league.seasons.where("lower(display_name) = ?",self.display_name.downcase).where.not(id: self.id).any?
      self.errors.add(:display_name,"has already been used for this league")
    end
  end

  def close_active_seasons
    self.update_table!
    self.league.seasons.closed.each{|s| s.destroy }
    self.league.seasons.active.each{|s| s.close! if s.may_close? }
  end
end
