class AddIndexShows < ActiveRecord::Migration

  def change
  	add_index :shows , :name
  	add_index :shows , :tvr_id
  end

end
