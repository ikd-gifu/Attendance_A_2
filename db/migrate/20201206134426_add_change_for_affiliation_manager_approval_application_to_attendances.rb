class AddChangeForAffiliationManagerApprovalApplicationToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :change_for_affiliation_manager_approval_application, :boolean, default: false
  end
end
