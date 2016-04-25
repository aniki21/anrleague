class CreateLigas < ActiveRecord::Migration
  def change
    create_table :ligas do |t|
      t.string :display_name
      t.integer :owner_id

      t.timestamps null: false
    end
  end
end
