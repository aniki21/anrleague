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
