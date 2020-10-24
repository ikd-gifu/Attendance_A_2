class AddChangeForAttendanceChangeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_for_attendance_change, :boolean, default: false
  end
end
