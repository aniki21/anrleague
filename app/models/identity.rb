class Identity < ActiveRecord::Base
  # Associations
  belongs_to :faction

  # Methods
  def nrdb_url
    "http://netrunnerdb.com/en/card/#{self.nrdb_id}"
  end
end
