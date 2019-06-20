class Memo < ActiveRecord::Base
  belongs_to :production
  belongs_to :user
  
  validates_presence_of     :contents
end
