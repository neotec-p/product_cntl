class Notice < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of     :contents
  
  before_save :prepare_save
  
  private

  def prepare_save
    self.created_ymd = Date.today
  end
end
