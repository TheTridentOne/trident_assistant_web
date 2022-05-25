class CreateMixinAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :mixin_assets, id: :uuid do |t|
      t.string :name
      t.jsonb :raw

      t.timestamps
    end
  end
end
