class LigaUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :liga
end
