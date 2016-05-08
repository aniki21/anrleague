class Faction < ActiveRecord::Base
  # Associations
  has_many :identities

  # Validations
  validates :display_name, presence: true, uniqueness: { case_sensitive: false }
  validates :icon_style, presence: true
  validates :side, presence: true

  # Callbacks

  # Scopes
  scope :runner, ->() { where(side: "runner") }
  scope :corp, ->() { where(side: "corp") }

  # Methods
  private
end
