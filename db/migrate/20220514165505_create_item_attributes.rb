class CreateItemAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :item_attributes, id: :uuid do |t|
      t.uuid :item_id
      t.uuid :attribute_id

      t.timestamps
    end

    add_index :item_attributes, [:item_id, :attribute_id], unique: true
  end
end
