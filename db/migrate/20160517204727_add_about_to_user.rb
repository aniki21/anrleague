class AddAboutToUser < ActiveRecord::Migration
  def change
    add_column :users, :about_markdown, :text
    add_column :users, :about_html, :text
  end
end
