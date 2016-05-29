class User < ActiveRecord::Base
  authenticates_with_sorcery!

  # Attribute Accessors
  attr_writer :suppress_notification
  def suppress_notification
    @suppress_notification || false
  end

  # Associations
  has_many :liga_users, dependent: :destroy
  has_many :leagues, through: :liga_users
  has_many :owned_leagues, -> { order(display_name: :asc) }, class_name: "Liga", foreign_key: "owner_id"
  has_many :reports_against, class_name: "ReportFlag", as: :reportee
  has_many :report_flags, foreign_key: "reporter_id"

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /.+@.+\..+/, message: "must be in a valid format" }
	validates_length_of :password, :minimum => 6, :message => "must be at least 6 characters long", if: :password
	validates_confirmation_of :password, :message => "should match password", if: :password
	validate :password_complexity, if: :password

	# Callbacks
  before_validation :render_markdown
	#before_save :notify_on_email_change

	# Scopes
	scope :activated, ->() { where(activation_state: "active") }
	scope :pending, ->() { where(activation_state: "active") }
	scope :notify_league_broadcast, ->() { where(notify_league_broadcast: true) }
	scope :notify_game_result, ->() { where(notify_game_result: true) }
	scope :notify_league_membership, ->() { where(notify_league_membership: true) }
	scope :notify_league_season, ->() { where(notify_league_season: true) }
	scope :notify_officer_game_result, ->() { where(notify_officer_game_result: true) }
	scope :notify_officer_league_membership, -> () { where(notify_officer_league_membership: true) }

  include AASM
  aasm do
    state :active, initial: true
    state :banned

    event :ban do
      transitions from: :active, to: :banned, after: Proc.new {|expiry_date| set_ban_expiry(expiry_date) }
    end

    event :unban do
      transitions from: :banned, to: :active, after: Proc.new {|expiry_date| set_ban_expiry(expiry_date) }
    end
  end

	# Methods
  def slug
    return self.display_name.parameterize
  end

	def games
    Game.for_player(self.id)
  end
	
	def member_of?(league)
    self.liga_users.where(liga_id:league.id).first
  end

  def membership_of(league)
    m = self.liga_users.where(liga_id:league.id).first
    return m.blank? ? false : (m.owner? ? "owner" : (m.officer? ? "officer" : (m.approved? ? "member" : "pending")))
  end

  def account_status
    return "banned" if banned?
    return "active" if activated?
    return "pending"
  end

  def activated?
    self.activation_state == "active"
  end

  private
  def password_complexity
    if /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/.match(self.password).blank?
      self.errors.add(:password,"must contain at least one upper and lower-case letter, and at least one number")
    end
  end

  def render_markdown
    self.about_html = MARKDOWN.render(self.about_markdown || "")
  end

  def set_ban_expiry(expiry_date)
    unless expiry_date.blank?
      self.ban_expires_at = expiry_date
    else
      self.ban_expires_at = nil
    end
    self.save(validate:false)
  end
end
