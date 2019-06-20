class ProcessOrder < ActiveRecord::Base
  belongs_to :production_detail
  belongs_to :trader

  has_and_belongs_to_many :reports

  validates_presence_of     :production_detail_id
  validates_numericality_of :production_detail_id

  validates_presence_of     :trader_id

  validates_presence_of     :order_ymd

  validates_presence_of     :delivery_ymd
  validates_date_compare_of :delivery_ymd, :type => :future_than_or_equal_to, :compare_to => 'order_ymd'

  validates_date_compare_of :arrival_ymd, :type => :future_than_or_equal_to, :compare_to => 'delivery_ymd'
  
  before_create :set_default
  
  # public class method ========================================================

  # accessor ===================================================================
  attr_accessor :no_in_list
  attr_accessor :select_print

  # public instance method =====================================================
  def lot
    return production.lot
  end
  def item
    return production.item
  end
  def production
    return production_detail.production
  end
  def process_detail
    return production_detail.process_detail
  end

  private

  # private instance method ====================================================
  def set_default
    self.print_flag = FLAG_OFF
  end

end
