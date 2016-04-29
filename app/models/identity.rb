class Identity < ActiveRecord::Base
  # Associations
  belongs_to :faction

  # Scopes
  scope :runner, ->() { where("faction_id = ANY(SELECT id FROM factions WHERE side = 'runner')") }
  scope :corp, ->() { where("faction_id = ANY(SELECT id FROM factions WHERE side = 'corp')") }

  # Methods
  delegate :icon_style, to: :faction
  
  def nrdb_url
    "http://netrunnerdb.com/en/card/#{self.nrdb_id}"
  end
end
