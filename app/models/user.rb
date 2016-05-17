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

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /.+@.+\..+/, message: "must be in a valid format" }
	validates_length_of :password, :minimum => 6, :message => "must be at least 6 characters long", if: :password
	validates_confirmation_of :password, :message => "should match password", if: :password
	validate :password_complexity, if: :password

	# Callbacks
  before_validation :render_markdown
	before_save :notify_on_email_change, on: :update

	# Scopes
	scope :notify_league_broadcast, ->() { where(notify_league_broadcast: true) }
	scope :notify_game_result, ->() { where(notify_game_result: true) }
	scope :notify_league_membership, ->() { where(notify_league_membership: true) }
	scope :notify_league_season, ->() { where(notify_league_season: true) }
	scope :notify_officer_game_result, ->() { where(notify_officer_game_result: true) }
	scope :notify_officer_league_membership, -> () { where(notify_officer_league_membership: true) }

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

  private
  # Do this on the model so that even if an admin changes the email,
  # a user will be notified (prevents support abuse)
  def notify_on_email_change
    email_changed = self.changes[:email]
    unless email_changed.blank?
      UserMailer.email_updated(self,email_changed.first).deliver_now! unless @suppress_notification
    end
  end

  def password_complexity
    if /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/.match(self.password).blank?
      self.errors.add(:password,"must contain at least one upper and lower-case letter, and at least one number")
    end
  end

  def render_markdown
    self.about_html = MARKDOWN.render(self.about_markdown || "")
  end
end
