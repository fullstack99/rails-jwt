class AddPermissionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :permission, :string, :default => "user"
  end
end
