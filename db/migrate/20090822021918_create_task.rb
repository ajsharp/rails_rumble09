class CreateTask < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :title, :null => false
      t.text :description
      t.datetime :action_by
      t.datetime :due_date
      t.integer :creator_id
      t.timestamps
    end
    
    add_index :tasks,:creator_id
  end

  def self.down
    remove_index :tasks,:creator_id
    drop_table :tasks
  end
end
