class AddFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :generated, :boolean, :default => false
  end

  def self.down
    remove_column :users, :generated
  end
end
