class AddNotifyLeagueJoinSeasonStartToUser < ActiveRecord::Migration
  def change
    add_column :users, :notify_league_membership, :boolean, default:true
    add_column :users, :notify_league_season, :boolean, default:true
  end
end
