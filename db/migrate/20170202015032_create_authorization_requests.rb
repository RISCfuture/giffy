class CreateAuthorizationRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :authorization_requests do |t|
      t.belongs_to :authorization, foreign_key: {on_delete: :cascade}

      t.string :code, null: false, limit: 64

      t.integer :status, null: false, limit: 1, default: AuthorizationRequest.statuses[:pending]
      t.text :error

      t.timestamps
    end
  end
end
