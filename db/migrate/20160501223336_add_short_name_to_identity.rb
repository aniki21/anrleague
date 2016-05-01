class AddShortNameToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :short_name, :string
  end
end
