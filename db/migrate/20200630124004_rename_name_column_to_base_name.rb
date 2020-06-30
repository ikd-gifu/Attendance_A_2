class RenameNameColumnToBaseName < ActiveRecord::Migration[5.1]
  def change
    rename_column :bases, :name, :base_name
  end
end
