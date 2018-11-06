class CreateStoredFilesTagsJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_table :stored_files_tags, id: false do |t|
      t.references :stored_file,  type: :uuid, null: false, index: true, foreign_key: true
      t.references :tag, null: false, index: true, foreign_key: true
    end
  end
end
