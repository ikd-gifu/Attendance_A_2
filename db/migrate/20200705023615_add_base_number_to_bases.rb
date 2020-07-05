class AddBaseNumberToBases < ActiveRecord::Migration[5.1]
  def change
    add_column :bases, :base_number, :integer
  end
end
