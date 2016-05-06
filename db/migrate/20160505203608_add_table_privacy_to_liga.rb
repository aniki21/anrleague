class AddTablePrivacyToLiga < ActiveRecord::Migration
  def change
    add_column :ligas, :table_privacy, :string, default: :public
  end
end
