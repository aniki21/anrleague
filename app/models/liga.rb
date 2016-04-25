class Liga < ActiveRecord::Base
  has_many :liga_users
  has_many :users, through: :liga_users
end
