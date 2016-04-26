class LigaUser < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :liga

  # Validations
  validates :user_id, presence: true
  validates :liga_id, presence: true
end
