class UserFavourite < ActiveRecord::Base
  self.table_name = "shows_users"
  belongs_to :show
  belongs_to :user
end