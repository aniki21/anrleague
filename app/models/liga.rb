class Liga < ActiveRecord::Base
  # Associations
  has_many :liga_users
  has_many :users, through: :liga_users
  belongs_to :owner, class_name: "User"

  # Validations
  validates :display_name, presence: true, uniqueness: true
end
