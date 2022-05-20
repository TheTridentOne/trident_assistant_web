class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items, id: :uuid do |t|
      t.uuid :collection_id, index: true
      t.uuid :token_id, index: true
      t.string :identifier, index: true
      t.string :metahash, index: true
      t.string :name
      t.text :description
      t.float :royalty
      t.jsonb :metadata
      t.string :state

      t.timestamps
    end
  end
end
