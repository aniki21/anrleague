class CreateFactions < ActiveRecord::Migration
  def change
    create_table :factions do |t|
      t.string :display_name
      t.string :icon_style

      t.timestamps null: false
    end
  end
end
