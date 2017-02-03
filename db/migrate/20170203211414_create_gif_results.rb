class CreateGIFResults < ActiveRecord::Migration[5.0]
  def change
    create_table :gif_results do |t|
      t.belongs_to :authorization, null: false, foreign_key: {on_delete: :cascade}

      t.string :channel_id, :user_id, :user_name, null: false, limit: 64
      t.string :query, :image_url, :response_url, null: false

      t.boolean :noped, null: false, default: false

      t.timestamps
    end
  end
end
