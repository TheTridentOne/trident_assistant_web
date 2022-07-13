class AddUniqueToItemTokenId < ActiveRecord::Migration[7.0]
  def change
    remove_index :items, :token_id
    add_index :items, :token_id, unique: true

    remove_index :items, :collection_id
    remove_index :items, :identifier
    add_index :items, [:collection_id, :identifier], unique: true
  end
end
