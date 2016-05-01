class AddLeagueTableToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :league_table, :text
  end
end
