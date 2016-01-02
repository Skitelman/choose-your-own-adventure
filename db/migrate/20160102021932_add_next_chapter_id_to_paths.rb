class AddNextChapterIdToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :next_chapter_id, :integer
  end
end
