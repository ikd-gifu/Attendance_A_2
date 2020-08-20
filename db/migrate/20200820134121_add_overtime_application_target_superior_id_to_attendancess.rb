class AddOvertimeApplicationTargetSuperiorIdToAttendancess < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_application_target_superior_id, :integer
  end
end
