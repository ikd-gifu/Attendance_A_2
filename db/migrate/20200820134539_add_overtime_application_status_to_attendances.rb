class AddOvertimeApplicationStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime_application_status, :string
  end
end
