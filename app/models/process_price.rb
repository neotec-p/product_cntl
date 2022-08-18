class ProcessPrice < ActiveRecord::Base
  belongs_to :item
  belongs_to :material
  belongs_to :trader

  validates_presence_of     :customer_code
  validates_length_of       :customer_code,  :maximum => 3
  validates_alphanumeric_of :customer_code

  validates_presence_of     :code
  validates_length_of       :code,  :maximum => 4
  validates_alphanumeric_of :code

  validates_presence_of     :material_id
  validates_presence_of     :trader_id

  validates_presence_of     :process

  validates_presence_of     :price
  validates_numericality_of :price, :allow_blank => true

  validates_numericality_of :addition_price, :allow_blank => true
  validates_numericality_of :condition_weight, :allow_blank => true

  validate :item_exist?

  before_save :create_relations
  
  # public class method ========================================================

  # accessor ===================================================================

  # public instance method =====================================================
  def disp_text
    return process
  end

  # private instance method ====================================================
  def item_exist?
    unless (customer_code.blank? || code.blank?)
      item = Item.findByItemCode(customer_code, code)
      if item.nil?
        errors.add(:customer_code, :not_exist)
        errors.add(:code, :not_exist)
      end
    end
  end

  def create_relations
    self.id = nil if self.new_record?
    
    self.item = Item.findByItemCode(customer_code, code)
  end

end
