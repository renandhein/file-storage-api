class CreateStoredFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :stored_files, id: :uuid do |t|
      t.string :name, limit: 100

      t.timestamps
    end
  end
end
