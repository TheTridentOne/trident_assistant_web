class AddSymbolToCollections < ActiveRecord::Migration[7.0]
  def change
    add_column :collections, :symbol, :string
  end
end
