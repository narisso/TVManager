class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.integer :tvr_id
      t.string :name
      t.integer :status
      t.string :country

      t.timestamps
    end
  end
end
