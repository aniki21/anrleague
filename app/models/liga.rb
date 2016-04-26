class Liga < ActiveRecord::Base
  # Allow location lookup
  acts_as_mappable lat_column_name: :latitude,
                   lng_column_name: :longitude

  # Associations
  has_many :liga_users
  has_many :users, through: :liga_users
  belongs_to :owner, class_name: "User"

  # Validations
  validates :display_name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50, message: "cannot be more than 50 characters" }

  # Scopes
  scope :online, ->() { where(location_type: "online") }
  scope :offline, ->() { where(location_type: "offline") }

  # Methods
  def slug
    self.display_name.parameterize
  end
  
  def online?
    self.location_type == "online"
  end

  def offline?
    self.location_type == "offline"
  end

  def nearby(radius=5)
    return Liga.offline.within(radius,origin:self) if self.offline?
    return []
  end
end
