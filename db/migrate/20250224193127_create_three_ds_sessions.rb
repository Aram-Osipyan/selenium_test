class CreateThreeDsSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :three_ds_sessions do |t|
      t.text :creq
      t.string :selenium_session_id
      t.string :uuid
      t.string :state, null: false, default: :created

      t.timestamps
    end
  end
end
