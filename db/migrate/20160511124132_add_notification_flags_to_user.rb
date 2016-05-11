class AddNotificationFlagsToUser < ActiveRecord::Migration
  def change
    add_column :users, :notify_league_broadcast, :boolean, default: true
  end
end
