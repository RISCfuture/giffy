class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :slack_id, null: false, limit: 40
      t.text :info
      t.timestamps null: false
    end

    add_index :users, :slack_id, unique: true
  end
end
