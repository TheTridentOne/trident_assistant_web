class AddTokenIdNotNullConstraintToNfo < ActiveRecord::Migration[7.0]
  def change
    change_column :non_fungible_outputs, :token_id, :uuid, null: false
  end
end
