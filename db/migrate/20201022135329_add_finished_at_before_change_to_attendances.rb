class AddFinishedAtBeforeChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :finished_at_before_change, :datetime
  end
end
