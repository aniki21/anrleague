class AddOfflineLocationToLiga < ActiveRecord::Migration
  def change
    add_column :ligas, :offline_location, :string
  end
end
