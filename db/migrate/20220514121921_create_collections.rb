class CreateCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :collections, id: :uuid do |t|
      t.uuid :creator_id, index: true
      t.string :name
      t.string :external_url
      t.text :description
      t.float :split
      t.jsonb :raw
      t.string :state

      t.timestamps
    end
  end
end
