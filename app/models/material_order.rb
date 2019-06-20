class MaterialOrder < ActiveRecord::Base
  belongs_to :material
  belongs_to :trader
  
  has_many :material_stocks

  has_and_belongs_to_many :reports

  validates_presence_of     :trader_id
  
  validates_presence_of     :order_ymd

  validates_presence_of     :delivery_ymd

  validates_numericality_of :purchase_price, :allow_blank => true

  validates_presence_of     :order_weight
  validates_numericality_of :order_weight, :allow_blank => true

  validates_presence_of     :delivery_flag
  
  validates_presence_of     :full_delivery_ymd, { :if => Proc.new {|x| x.delivery_flag == FLAG_ON } }

  before_create :set_default
  before_save :material_update
  
  # public class method ========================================================
  def accept_weights
    material_stocks.sum(
    :accept_weight
    )
  end

  # accessor ===================================================================
  attr_accessor :no_in_list
  attr_accessor :select_print
  attr_accessor :price
  attr_accessor :material_update_flag

  # public instance method =====================================================
  def disp_delivery_flag
    disp = I18n.t(:status_delivery_flag_yet)
    disp = I18n.t(:status_delivery_flag_full) if delivery_flag == FLAG_ON
    
    return disp
  end

  def deletable?
    unless material_stocks.empty?
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
  
  def material_update
    unless material_update_flag.blank?
      unless purchase_price.blank?
        if material.unit_price_update_flag == FLAG_ON
          material.unit_price = purchase_price
          material.save!
        end
      end
    end
  end
  
end
