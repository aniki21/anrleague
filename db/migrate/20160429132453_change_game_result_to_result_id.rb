class ChangeGameResultToResultId < ActiveRecord::Migration
  def change
    rename_column :games, :result, :result_id
  end
end
