class AddNotifyOwnedLeagueGameResultsToUser < ActiveRecord::Migration
  def change
    add_column :users, :notify_officer_game_result, :boolean, default:true
  end
end
