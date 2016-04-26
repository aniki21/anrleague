class AddDisplayFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :display_name, :string
    add_column :users, :jinteki_username, :string
  end
end
