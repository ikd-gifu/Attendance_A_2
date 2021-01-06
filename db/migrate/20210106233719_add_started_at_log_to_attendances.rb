class AddStartedAtLogToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :started_at_log, :datetime
  end
end
