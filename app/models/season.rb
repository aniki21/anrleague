class Season < ActiveRecord::Base
  # Associations
  belongs_to :league, class_name: "Liga"
  has_many :games

  # Validations
  validates :league_id, presence: true
  validates :display_name, presence: true
  validate :display_name_unique_for_league

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
  
  def table
    JSON.parse(self.league_table || "[]").map(&:symbolize_keys)
  end

  def update_table
    # automatically go through all games and
    # build the league table

    # { player_id: { name: "name", played: 0, wins: 0, losses: 0, draws: 0, ap: 0, lp: 0 }
    _table = {}

    games.each do |game|
      runner = game.runner_player
      corp = game.corp_player
      # initialize the players' league rows
      _table[:"#{runner.id}"] ||= { name: runner.display_name, played: 0, wins: 0, losses: 0, draws: 0, ap: 0, lp: 0 }
      _table[:"#{corp.id}"] ||= { name: corp.display_name, played: 0, wins: 0, losses: 0, draws: 0, ap: 0, lp: 0 }

      # result
      unless game.result_id.blank?
        _table[:"#{runner.id}"][:ap] += game.runner_agenda_points
        _table[:"#{corp.id}"][:ap] += game.corp_agenda_points

        if game.runner_win?
          # runner win
          _table[:"#{runner.id}"][:wins] += 1
          _table[:"#{runner.id}"][:lp] += game.league.points_for_win
          _table[:"#{corp.id}"][:losses] += 1
          _table[:"#{corp.id}"][:lp] += game.league.points_for_loss
        elsif game.corp_win?
          _table[:"#{runner.id}"][:losses] += 1
          _table[:"#{runner.id}"][:lp] += game.league.points_for_loss
          _table[:"#{corp.id}"][:wins] += 1
          _table[:"#{corp.id}"][:lp] += game.league.points_for_win
          # corp win
        elsif game.draw?
          # points for everybody!
          _table[:"#{runner.id}"][:draws] += 1
          _table[:"#{runner.id}"][:lp] += game.league.points_for_draw
          _table[:"#{corp.id}"][:draws] += 1
          _table[:"#{corp.id}"][:lp] += game.league.points_for_draw
        else
          # nothing?
        end
      else
        # do nothing
      end
    end
    
    _table = _table.map(&:last)
    _table = _table.sort do |a,b|
      comp = (b[:lp] <=> a[:lp])
      comp.zero? ? (b[:ap] <=> a[:ap]) : comp
    end

    self.league_table = _table.to_json
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
    self.league.seasons.active.each{|s| s.close! if s.may_close }
  end
end
