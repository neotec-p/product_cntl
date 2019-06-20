class AsynchroStatus < ActiveRecord::Base
  has_many :summations
  has_many :reports
end
