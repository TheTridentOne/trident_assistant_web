class CreateAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :attributes, id: :uuid do |t|
      t.string :name
      t.string :value

      t.timestamps
    end

    add_index :attributes, [:name, :value], unique: true
  end
end
