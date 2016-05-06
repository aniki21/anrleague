class AddActivatedAtToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :activated_at, :datetime
  end
end
