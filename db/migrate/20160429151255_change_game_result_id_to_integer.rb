class ChangeGameResultIdToInteger < ActiveRecord::Migration
  def change
    change_column :games, :result_id, 'integer USING CAST(result_id AS integer)'
  end
end
