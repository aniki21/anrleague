class Identity < ActiveRecord::Base
  # Associations
  belongs_to :faction

  # Validations
  validates :display_name, presence: true, uniqueness: { case_sensitive: false }
  validates :faction_id, presence: true
  validates :nrdb_id, uniqueness: true, allow_nil: true

  # Scopes
  scope :runner, ->() { where("faction_id = ANY(SELECT id FROM factions WHERE side = 'runner')") }
  scope :corp, ->() { where("faction_id = ANY(SELECT id FROM factions WHERE side = 'corp')") }

  # Methods
  delegate :icon_style, to: :faction
  
  def nrdb_url
    return "http://netrunnerdb.com/en/card/#{self.nrdb_id}" unless self.nrdb_id.blank?
    return nil
  end
end
