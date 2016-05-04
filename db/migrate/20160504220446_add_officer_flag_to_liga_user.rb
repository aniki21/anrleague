class AddOfficerFlagToLigaUser < ActiveRecord::Migration
  def change
    add_column :liga_users, :officer, :boolean, default: false
  end
end
