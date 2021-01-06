class AddFinishedAtLogToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :finished_at_log, :datetime
  end
end
