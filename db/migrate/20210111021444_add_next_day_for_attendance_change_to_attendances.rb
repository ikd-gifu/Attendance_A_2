class AddNextDayForAttendanceChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :next_day_for_attendance_change, :boolean, default: false
  end
end
