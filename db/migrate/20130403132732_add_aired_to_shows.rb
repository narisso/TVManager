class AddAiredToShows < ActiveRecord::Migration
  
  def change
  	add_column :shows, :started, :string, :default => "Not yet processed"
  end

end
