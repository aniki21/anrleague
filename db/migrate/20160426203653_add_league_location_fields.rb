class AddLeagueLocationFields < ActiveRecord::Migration
  def change
    add_column :ligas, :location_type, :string
    add_column :ligas, :online_location, :string
    add_column :ligas, :latitude, :decimal, default: 0.0
    add_column :ligas, :longitude, :decimal, default: 0.0

    add_index :ligas, :location_type
  end
end
