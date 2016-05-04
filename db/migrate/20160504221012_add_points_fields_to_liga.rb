class AddPointsFieldsToLiga < ActiveRecord::Migration
  def change
    add_column :ligas, :points_for_win, :integer, default: 3
    add_column :ligas, :points_for_draw, :integer, default: 1
    add_column :ligas, :points_for_loss, :integer, default: 0
  end
end
