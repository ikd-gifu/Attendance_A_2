class AddAttendanceChangeApplicationTargetSuperiorIdToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :attendance_change_application_target_superior_id, :integer
  end
end
