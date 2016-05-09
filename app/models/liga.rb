class Liga < ActiveRecord::Base
  per_page = 20
  @allowed_location_types = %w(online offline)
  @allowed_memberships = %w(open closed invitational)
  @allowed_table_privacies = %w(public private)

  # Allow location lookup
  acts_as_mappable lat_column_name: :latitude,
                   lng_column_name: :longitude

  # Associations
  belongs_to :owner, class_name: "User"
  has_many :liga_users, ->() { order(created_at: :asc) }, dependent: :destroy
  has_many :users, through: :liga_users
  has_many :seasons, foreign_key: "league_id", dependent: :destroy
  has_many :games, through: :seasons

  # Validations
  validates :display_name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: {
      maximum: 50,
      message: "cannot be more than 50 characters"
    }
  validates :location_type,
    presence: true,
    inclusion: {
      in: %w(online offline),
      message: "must be online or offline"
    }
  validates :privacy,
    presence: true,
    inclusion: {
      in: %w(open closed invitational),
      message: "must be a valid option"
    }
  validates :table_privacy,
    presence: true,
    inclusion: {
      in: %w(public private),
      message: "must be a valid option"
    }
  validates :offline_location,
    presence: { message: "must be provided for offline leagues" },
    if: :offline?
  validates :online_location,
    presence: { message: "must be provided for offline leagues" },
    if: :online?

  # Scopes
  scope :online, ->() { where(location_type: "online") }
  scope :offline, ->() { where(location_type: "offline") }

  # Privacy
  #   Open - anyone can join, table is public
  #   Invitational - owner can invite new players, table is visible only to members
  #   Private - requests must be approved by owner/officers, table is visible only to members
  scope :open, ->() { where(privacy: "open") }
  scope :invitational, ->() { where(privacy: "invitational") }
  scope :closed, ->() { where(privacy: "closed") }

  # Callbacks
  before_validation :render_markdown
  before_validation :set_offline_location, if: :offline?

  #
  # Methods
  #

  # Users and memberships
  def players
    approved_user_ids = (self.liga_users.map(&:user_id) + [self.owner_id]).uniq
    return User.where(id: approved_user_ids).order("lower(display_name) ASC")
  end

  def approved_players
    approved_user_ids = (self.liga_users.approved.map(&:user_id) + [self.owner_id]).uniq
    return User.where(id: approved_user_ids).order("lower(display_name) ASC")
  end

  def officers
    self.liga_users.officers
  end

  def user_is_officer?(user)
    self.officers.include?(user) || user.id == self.owner_id || user.admin?
  end
  
  def slug
    self.display_name.parameterize
  end

  # Privacy
  def open?
    self.privacy == "open"
  end

  def closed?
    self.privacy == "closed"
  end

  def invitational?
    self.privacy == "invitational"
  end

  # Location functions
  def self.location_types
    @location_types
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

  def nearby(radius=5)
    return Liga.offline.within(radius,origin:self) if self.offline?
    return []
  end

  def latlong
    return "#{latitude},#{longitude}"
  end

  # Management
  def user_can_edit?(user_id)
    return user_id == owner_id
  end

  # Search
  # This is /incrediby/ basic
  def self.search(query)
    q = "%#{query.gsub(/\s/,"%")}%".downcase
    self.where("lower(display_name) LIKE ? OR lower(offline_location) LIKE ?",q,q)
  end

  private
  def render_markdown
    self.description_html = MARKDOWN.render(self.description_markdown || "")
  end

  def set_offline_location
    unless self.latlong.blank?
      lookup = Geokit::Geocoders::GoogleGeocoder.reverse_geocode self.latlong
      loc = []
      loc.push(lookup.city) unless lookup.city.blank?
      loc.push(lookup.state) unless lookup.state.blank?
      loc.push(lookup.country) unless lookup.country.blank?

      self.offline_location = loc.join(", ")    
    end
  end
end
