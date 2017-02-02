class CreateAuthorizations < ActiveRecord::Migration[5.0]
  def change
    create_table :authorizations do |t|
      t.string :access_token, :scope, null: false, limit: 128

      t.string :team_name, limit: 128
      t.string :team_id, null: false, limit: 20

      t.string :incoming_webhook_url, limit: 255
      t.string :incoming_webhook_channel, limit: 128
      t.string :incoming_webhook_config_url, limit: 255

      t.timestamps
    end

    add_index :authorizations, :team_id, unique: true
    add_index :authorizations, :team_name
  end
end
