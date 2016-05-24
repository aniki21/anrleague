class LigaUser < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :league, class_name: "Liga", foreign_key: "liga_id"

  # Validations
  validates :user_id, presence: true, unless: :invitation_token
  validates :liga_id, presence: true
  validates :invitation_token, presence: true, uniqueness: true, allow_nil: true, unless: :user_id
  validate :user_unique_in_liga

  # Scopes
  scope :officers, ->() { where(officer: true) }
  scope :not_banned, ->() { where.not(aasm_state: "banned") }
  scope :pending, ->() { where("aasm_state = ? OR aasm_state = ?","requested","invited") }

  # States
  include AASM
  aasm do
    state :requested, initial:true
    state :invited, before_enter: :set_invitation_token
    state :approved, before_enter: :clear_invitation_token
    state :banned

    # Membership approved
    event :approve do
      transitions from: [:requested], to: :approved
    end
    
    # Invitational
    event :invite do
      transitions from: :requested, to: :invited
    end
    event :accept do
      transitions from: :invited, to: :approved
    end
    # event :reject is just a deletion of the LigaUser

    # Banning
    event :ban do
      before do
        cancel_unplayed_games
      end
      transitions from: [:approved], to: :banned, guard: :bannable?
    end
    event :unban do
      before do
        reactivate_cancelled_games
      end
      transitions from: [:banned], to: :approved
    end
  end

  # Methods
  delegate :email, to: :user
  delegate :display_name, to: :user

  def display_name
    return self.user.display_name unless self.user.blank?
    return self.invitation_token if self.invited?
    return "Unknown"
  end

  def promote!
      self.update_attribute(:officer,true) if self.may_promote?
  end

  def may_promote?
    return self.approved? && !self.officer?
  end

  def demote!
    self.update_attribute(:officer,false) if self.may_demote?
  end

  def may_demote?
    return self.approved? && self.officer?
  end

  def owner?
    self.league.owner_id == self.user_id
  end
  
  private
  def user_unique_in_liga
    self.errors.add(:base,"#{self.user.display_name} is already a member of #{self.league.display_name}") if LigaUser.where(user_id:self.user_id,liga_id:self.liga_id).where.not(id:self.id).any? && !self.user_id.blank?
  end

  def set_invitation_token
    if self.user_id.blank?
      self.invitation_token = generate_token
    end
  end

  def clear_invitation_token
    self.invitation_token = nil
  end

  def generate_token(length=10)
    return (0...length).map{ RANDOM_CHARS[rand(RANDOM_CHARS.length)] }.join    
  end

  def bannable?
    return false if self.officer?
    return true
  end

  def cancel_unplayed_games
    self.user.games.unplayed.each{|g| g.cancel! }
  end

  def reactivate_cancelled_games
    self.user.games.cancelled.each{|g| g.update_attribute(:result_id, nil) }
  end
end
