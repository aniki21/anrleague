class Faction < ActiveRecord::Base
  # Associations
  has_many :identities

  # Validations
  validates :display_name, presence: true, uniqueness: { case_sensitive: false }

  # Callbacks
  before_save :set_icon_style

  # Scopes
  scope :runner, ->() { where(side: "runner") }
  scope :corp, ->() { where(side: "corp") }

  # Methods
  private
  def set_icon_style
    self.icon_style ||= self.display_name.parameterize
  end
end
