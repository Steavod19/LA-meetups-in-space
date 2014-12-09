class Comment < ActiveRecord::Base
  belongs_to :meet_up
  belongs_to :users

end
