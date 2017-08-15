class IncreaseAuthCodeSizeTo128 < ActiveRecord::Migration[5.1]
  def change
    change_column :authorization_requests, :code, :string, null: false, limit: 128
  end
end
