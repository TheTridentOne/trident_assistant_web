class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    enable_extension 'citext' unless extension_enabled?('citext')

    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :mixin_id
      t.text :keystore
      t.jsonb :raw

      t.timestamps
    end
  end
end
