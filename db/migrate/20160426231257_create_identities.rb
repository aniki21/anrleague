class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.integer :faction_id
      t.string :display_name
      t.string :nrdb_id

      t.timestamps null: false
    end
  end
end
