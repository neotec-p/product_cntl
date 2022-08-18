class ProcessRatio < ActiveRecord::Base

  validates_numericality_of :hd, :allow_blank => true
  validates_numericality_of :barrel, :allow_blank => true
  validates_numericality_of :ro1, :allow_blank => true
  validates_numericality_of :ro2, :allow_blank => true
  validates_numericality_of :heat, :allow_blank => true
  validates_numericality_of :surface, :allow_blank => true

end
