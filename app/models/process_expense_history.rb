class ProcessExpenseHistory < ActiveRecord::Base
  belongs_to :item
  belongs_to :process_expense
  
  validates_numericality_of :hd, :allow_blank => true
  validates_numericality_of :barrel, :allow_blank => true
  validates_numericality_of :hd_addition, :allow_blank => true
  validates_numericality_of :ro1, :allow_blank => true
  validates_numericality_of :ro1_addition, :allow_blank => true
  validates_numericality_of :ro2, :allow_blank => true
  validates_numericality_of :ro2_addition, :allow_blank => true
  validates_numericality_of :heat, :allow_blank => true
  validates_numericality_of :heat_addition, :allow_blank => true
  validates_numericality_of :surface, :allow_blank => true
  validates_numericality_of :surface_addition, :allow_blank => true
  validates_numericality_of :inspection, :allow_blank => true
  validates_numericality_of :inspection_addition, :allow_blank => true
  
  validates_numericality_of :ratio_hd, :allow_blank => true
  validates_numericality_of :ratio_barrel, :allow_blank => true
  validates_numericality_of :ratio_ro1, :allow_blank => true
  validates_numericality_of :ratio_ro2, :allow_blank => true
  validates_numericality_of :ratio_heat, :allow_blank => true
  validates_numericality_of :ratio_surface, :allow_blank => true
  
end
