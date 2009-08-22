class CreateConnections < ActiveRecord::Migration
  def self.up
    create_table :connections do |t|
      t.integer :user_id
      t.integer :friend_id
      t.string  :status
      t.datetime :accepted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :connections
  end
end
