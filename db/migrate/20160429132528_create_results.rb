class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :display_name
      t.string :winning_side

      t.timestamps null: false

      t.index :winning_side
    end
  end
end
