class AddNotifyGameResultToUser < ActiveRecord::Migration
  def change
    add_column :users, :notify_game_result, :boolean, default: true
  end
end
