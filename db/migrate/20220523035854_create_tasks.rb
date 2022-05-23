class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks, id: :uuid do |t|
      t.uuid :user_id, index: true
      t.uuid :collection_id
      t.uuid :token_id
      t.string :type
      t.jsonb :params, default: {}
      t.jsonb :result, default: {}
      t.string :state
      t.datetime :processed_at

      t.timestamps
    end
  end
end
