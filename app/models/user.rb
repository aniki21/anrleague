class User < ActiveRecord::Base
  authenticates_with_sorcery!

  # Associations
  has_many :liga_users
  has_many :ligas, through: :liga_users

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /.+@.+\..+/, message: "must be in a valid format" }
	validates_length_of :password, :minimum => 6, :message => "must be at least 6 characters long", :if => :password
	validates_confirmation_of :password, :message => "should match password", :if => :password
end
