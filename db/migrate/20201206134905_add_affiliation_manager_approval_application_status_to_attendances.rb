class AddAffiliationManagerApprovalApplicationStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :affiliation_manager_approval_application_status, :string
  end
end
