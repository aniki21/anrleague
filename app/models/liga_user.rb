class LigaUser < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :league, class_name: "Liga", foreign_key: "liga_id"

  # Validations
  validates :user_id, presence: true
  validates :liga_id, presence: true
  validate :user_unique_in_liga

  # Scopes
  scope :officers, ->() { where(officer: true) }

  # States
  include AASM
  aasm do
    state :requested, initial:true # User requests join
    state :invited                 # Owner invites user
    state :approved                # Request/invitation accepted
    state :banned                  # Player banned

    event :approve do
      transitions from: [:requested,:invited], to: :approved
    end

    event :ban do
      transitions from: [:requested,:approved], to: :banned
    end
  end

  # Methods
  delegate :display_name, to: :user

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
  
  private
  def user_unique_in_liga
    self.errors.add(:base,"#{self.user.display_name} is already a member of #{self.league.display_name}") if LigaUser.where(user_id:self.user_id,liga_id:self.liga_id).where.not(id:self.id).any? #|| self.league.owner_id == self.user_id
  end
end
