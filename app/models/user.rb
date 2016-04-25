class User < ActiveRecord::Base
  authenticates_with_sorcery!

  # Associations
  has_many :liga_users
  has_many :ligas, through: :liga_users

end
