class LigaUser < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :league, class_name: "Liga", foreign_key: "liga_id"

  # Validations
  validates :user_id, presence: true
  validates :liga_id, presence: true
end
