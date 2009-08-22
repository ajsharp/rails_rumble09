class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer   :task_id
      t.integer   :user_id
      t.text      :message
      
      # paperclip attachment
      t.string    :attachment_file_name
      t.string    :attachment_content_type
      t.integer   :attachment_file_size
      t.datetime  :attachment_updated_at
      
      # magic columns
      t.timestamps
    end
    
    add_index :comments, :task_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
