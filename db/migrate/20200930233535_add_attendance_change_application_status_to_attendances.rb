class AddAttendanceChangeApplicationStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_change_application_status, :string
  end
end
