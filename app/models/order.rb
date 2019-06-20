class Order < ActiveRecord::Base
  has_many :productions, :dependent => :delete_all
  accepts_nested_attributes_for :productions, :reject_if => proc { |a| a[:vote_no].blank? }

  validates_presence_of     :order_no
  validates_alphanumeric_of :order_no
  validates_presence_of     :order_ymd

  validates_presence_of     :order_amount
  validates_numericality_of :order_amount, :greater_than_or_equal_to => 0

  validates_presence_of     :delivery_ymd
  validates_date_compare_of :delivery_ymd, :type => :future_than_or_equal_to, :compare_to => 'order_ymd'

  validates_presence_of     :item_customer_code
  validates_length_of       :item_customer_code,  :maximum => 3
  validates_alphanumeric_of :item_customer_code

  validates_presence_of     :item_code
  validates_length_of       :item_code,  :maximum => 4
  validates_alphanumeric_of :item_code

  validates_numericality_of :necessary_amount, :greater_than_or_equal_to => 0, :allow_blank => true

  before_validation :do_validate?
  validate :item_exist?

  # public class method ========================================================
  def self.delivery_ymd_asc
    "orders.delivery_ymd asc"
  end

  # accessor ===================================================================
  attr_accessor :item_customer_code
  attr_accessor :item_code

  attr_accessor :force_validate

  attr_accessor :sum_result_amount
  attr_accessor :vote_no

  # public instance method =====================================================
  def include?
    result = true
    result = false if (order_amount.blank? && delivery_ymd.blank? && item_customer_code.blank? && item_code.blank?)
    return result
  end

  def create_relations
    self.id = nil if self.new_record?
    
    vote_no = Production.maximum(:vote_no)
    if vote_no.nil?
      vote_no = VOTE_NO_INIT
    end
    vote_no += 1

    unless productions.empty?
      production = productions.first
      vote_no = production.vote_no
      production.destroy
    end
  
    self.formation_ymd = Date.today
    
    item = Item.findByItemCode(item_customer_code, item_code)
  
    production = Production.new
    production.status_id = DEFAULT_PRODUCTION_STATUS_ID
    production.vote_no = vote_no
    production.branch1_no = DEFAULT_PRODUCTION_BRANCH1_NO
    production.branch2_no = DEFAULT_PRODUCTION_BRANCH2_NO
    
    production.customer_code = item.customer_code
    production.code = item.code
    production.print_flag = FLAG_OFF
  
    production.order = self
    production.item = item
  
    productions << production
  
    process_details = item.process_details
    process_details.each { |process_detail|
      next if process_detail.name.blank?
      production_detail = ProductionDetail.new
      production_detail.production = production
      production_detail.process_detail = process_detail
  
      production_detail.result_amount_production = 0 if process_detail.process_type.protected_flag == PROTECTED_FLAG_START
          
      production.production_details << production_detail
    }
  
    material = item.material
  
    material_production_seq = MaterialProductionSeq.new
    material_production_seq.material = material
    material_production_seq.production = production
    material_production_seq.seq = 1

    production.material_production_seqs << material_production_seq
  
    washer1 = item.washer1
    unless washer1.nil?
      washer_production_seq = WasherProductionSeq.new
      washer_production_seq.washer = washer1
      washer_production_seq.production = production
      washer_production_seq.seq = 1
      production.washer_production_seqs << washer_production_seq
    end
  
    washer2 = item.washer2
    unless washer2.nil?
      washer_production_seq = WasherProductionSeq.new
      washer_production_seq.washer = washer2
      washer_production_seq.production = production
      washer_production_seq.seq = 2
      production.washer_production_seqs << washer_production_seq
    end
  
    production.parts_fix_flag = FLAG_OFF
  end
  
  private

  # private instance method ====================================================
  def item_exist?
    unless (item_customer_code.blank? || item_code.blank?)
      item = Item.findByItemCode(item_customer_code, item_code)
      if item.nil?
        errors.add(:item_customer_code, :not_exist)
        errors.add(:item_code, :not_exist)
      elsif !item.valid_relations?
        errors.add(:item_customer_code, :not_exist)
        errors.add(:item_code, :not_exist)
      end
    end
  end

  def do_validate?
    return true if force_validate
    return include?
  end

end
