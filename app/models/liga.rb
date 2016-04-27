class Liga < ActiveRecord::Base
  # Allow location lookup
  acts_as_mappable lat_column_name: :latitude,
                   lng_column_name: :longitude

  # Associations
  has_many :liga_users
  has_many :users, through: :liga_users
  belongs_to :owner, class_name: "User"
  has_many :seasons, foreign_key: "league_id"
  has_many :games, through: :seasons

  # Validations
  validates :display_name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50, message: "cannot be more than 50 characters" }

  # Scopes
  scope :online, ->() { where(location_type: "online") }
  scope :offline, ->() { where(location_type: "offline") }

  # Callbacks
  before_validation :render_markdown
  before_validation :set_offline_location, if: :offline?

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

  def current_season
    self.seasons.active.last || self.seasons.closed.last
  end

  # Location functions
  def nearby(radius=5)
    return Liga.offline.within(radius,origin:self) if self.offline?
    return []
  end

  def latlong
    return "#{latitude},#{longitude}"
  end


  private
  def render_markdown
    self.description_html = MARKDOWN.render(self.description_markdown)
  end

  def set_offline_location
      lookup = Geokit::Geocoders::GoogleGeocoder.reverse_geocode self.latlong
      loc = []
      loc.push(lookup.city) unless lookup.city.blank?
      loc.push(lookup.state) unless lookup.state.blank?
      loc.push(lookup.country) unless lookup.country.blank?

      self.offline_location = loc.join(", ")    
  end
end
