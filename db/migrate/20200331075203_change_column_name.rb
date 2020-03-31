class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
  	rename_column :users, :verfication, :verification
  end
end
