class LigaUser < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :league, class_name: "Liga", foreign_key: "liga_id"

  # Validations
  validates :user_id, presence: true
  validates :liga_id, presence: true
  validate :user_unique_in_liga

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
  private
  def user_unique_in_liga
    self.errors.add(:user,"is already a member of this League") if LigaUser.where(user_id:self.user_id,liga_id:self.liga_id).where.not(id:self.id).any? || self.league.owner_id == self.user_id
  end
end
