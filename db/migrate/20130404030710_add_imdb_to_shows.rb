class AddImdbToShows < ActiveRecord::Migration
  def change
    	add_column :shows, :imdb_id, :string
  end
end
