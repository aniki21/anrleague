class CreateLigaUsers < ActiveRecord::Migration
  def change
    create_table :liga_users do |t|
      t.integer :user_id
      t.integer :liga_id

      t.timestamps null: false
    end
  end
end
