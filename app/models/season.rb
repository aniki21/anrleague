class Season < ActiveRecord::Base
  belongs_to :league, class_name: "Liga"
  has_many :games
end
