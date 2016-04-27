class AddSideToFactions < ActiveRecord::Migration
  def change
    add_column :factions, :side, :string
    add_index :factions, :side
  end
end
