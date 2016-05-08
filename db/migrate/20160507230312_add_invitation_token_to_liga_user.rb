class AddInvitationTokenToLigaUser < ActiveRecord::Migration
  def change
    add_column :liga_users, :invitation_token, :string
  end
end
