class CreateMixinMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :mixin_messages, id: :uuid do |t|
      t.uuid :sender_id, index: true
      t.uuid :recipient_id, index: true
      t.jsonb :raw, default: {}
      t.datetime :processed_at

      t.timestamps
    end
  end
end
