class AddPrivacyToLiga < ActiveRecord::Migration
  def change
    add_column :ligas, :privacy, :string, default: "public"

    add_index :ligas, :privacy
  end
end
