class Lot < ActiveRecord::Base
  belongs_to :production

  validates_presence_of     :lot_no
  validates_numericality_of :lot_no

  validates_numericality_of :weight, :allow_blank => true
  validates_numericality_of :case, :allow_blank => true

  validates_presence_of     :insert_ymd

end
