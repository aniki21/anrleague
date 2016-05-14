class AddNotifyOfficerLeagueMembershipToUser < ActiveRecord::Migration
  def change
    add_column :users, :notify_officer_league_membership, :boolean, default: true
  end
end
