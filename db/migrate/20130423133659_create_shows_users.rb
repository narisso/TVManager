class CreateShowsUsers < ActiveRecord::Migration
  def change
  	create_table :shows_users do |t|
      t.references :show 
      t.references :user
      t.timestamps
    end
  end

end
