class WasherOrder < ActiveRecord::Base
  belongs_to :washer
  belongs_to :trader
  
  has_many :washer_stocks

  has_and_belongs_to_many :reports
  
  validates_presence_of     :trader_id
  
  validates_presence_of     :order_ymd

  validates_presence_of     :delivery_ymd

  validates_numericality_of :purchase_price, :allow_blank => true
  
  validates_presence_of     :order_quantity
  validates_numericality_of :order_quantity, :allow_blank => true

  validates_presence_of     :delivery_flag
  
  validates_presence_of     :full_delivery_ymd, { :if => Proc.new {|x| x.delivery_flag == FLAG_ON } }

  before_create :set_default
  
  # public class method ========================================================
  def accept_quantities
    washer_stocks.sum(
    :accept_quantity
    )
  end

  # accessor ===================================================================
  attr_accessor :no_in_list
  attr_accessor :select_print
  attr_accessor :price

  # public instance method =====================================================
  def disp_delivery_flag
    disp = I18n.t(:status_delivery_flag_yet)
    disp = I18n.t(:status_delivery_flag_full) if delivery_flag == FLAG_ON
    
    return disp
  end

  def deletable?
    unless washer_stocks.empty?
      errors[:base] << I18n.t(:error_delete_relation)
      return false
    end
    
    return true
  end

  private

  # private instance method ====================================================
  def set_default
    self.print_flag = FLAG_OFF
  end
    
end
