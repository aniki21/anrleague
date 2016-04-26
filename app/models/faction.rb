class Faction < ActiveRecord::Base
  has_many :identities

  validates :display_name, presence: true, uniqueness: { case_sensitive: false }

  before_save :set_icon_style

  private
  def set_icon_style
    self.icon_style ||= self.display_name.parameterize
  end
end
