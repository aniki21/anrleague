class User < ActiveRecord::Base
  authenticates_with_sorcery!

  # Associations
  has_many :liga_users, dependent: :destroy
  has_many :leagues, through: :liga_users
  has_many :owned_leagues, -> { order(display_name: :asc) }, class_name: "Liga", foreign_key: "owner_id"

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /.+@.+\..+/, message: "must be in a valid format" }
	validates_length_of :password, :minimum => 6, :message => "must be at least 6 characters long", :if => :password
	validates_confirmation_of :password, :message => "should match password", :if => :password

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
    return m.blank? ? false : (m.officer? ? "officer" : "member")
  end
end
