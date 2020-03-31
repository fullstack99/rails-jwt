class VerificationToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :verfication, :boolean, :default => false
  end
end
