class AddStatusAndAssignerToAssignment < ActiveRecord::Migration
  def self.up
    rename_column :assignments, :user_id, :assignee_id
    change_table :assignments do |t|
      t.integer :assigner_id
      t.string :status
    end
  end

  def self.down
    rename_column :assignments, :assignee_id, :user_id
    change_table :assignments do |t|
      t.remove :assigner_id
      t.remove :status
    end
  end
end
