class AddStartedAtAfterChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_at_after_change, :datetime
  end
end
