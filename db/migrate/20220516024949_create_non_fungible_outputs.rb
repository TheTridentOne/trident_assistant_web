class CreateNonFungibleOutputs < ActiveRecord::Migration[7.0]
  def change
    create_table :non_fungible_outputs, id: :uuid do |t|
      t.uuid :user_id, index: true
      t.uuid :token_id, index: true
      t.string :state
      t.jsonb :raw

      t.timestamps
    end
  end
end
