class AddFinishedAtAfterChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :finished_at_after_change, :datetime
  end
end
