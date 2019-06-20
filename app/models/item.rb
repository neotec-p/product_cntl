class Item < ActiveRecord::Base
  belongs_to :customer

  has_one :process_expense, :dependent => :destroy
  has_one :header_right_check_sheet, :dependent => :destroy
  has_one :header_left_check_sheet, :dependent => :destroy
  has_one :rolling_right_check_sheet, :dependent => :destroy
  has_one :rolling_left_check_sheet, :dependent => :destroy

  has_many :process_details, :dependent => :destroy
  has_many :productions
  has_many :defectives

  has_many :item_material_seqs, :dependent => :destroy
  accepts_nested_attributes_for :item_material_seqs, :reject_if => proc { |a| a.new_record? }
  has_many :materials, :through => :item_material_seqs

  has_many :item_washer_seqs, :dependent => :destroy
  accepts_nested_attributes_for :item_washer_seqs, :reject_if => proc { |a| a.new_record? }
  has_many :washers, :through => :item_washer_seqs

  validates_presence_of     :customer_code
  validates_length_of     :customer_code,  :maximum => 3

  validates_presence_of     :code
  validates_length_of     :code,  :maximum => 4

  validates_presence_of     :drawing_no

  validates_presence_of     :name

  validates_presence_of     :price
  validates_numericality_of :price, :allow_blank => true

  validates_presence_of     :weight
  validates_numericality_of :weight, :allow_blank => true

  validate :customer_exist?
  
  # public class method ========================================================
  def self.findByItemCode(customer_code, code)
    #self.find_all_by_customer_code_and_code(customer_code, code).first
    self.where("customer_code = ? AND code = ?", customer_code, code).first
  end

  # accessor ===================================================================
  attr_accessor :tanaka
  attr_accessor :environment

  # public instance method =====================================================
  def tanaka
    #工程詳細の表面処理のデータ検索
    process_detail = process_details.includes(:process_type).where.not(process_details: {tanaka_flag: nil}).where(process_types: {processor_flag: PROCESSOR_FLAG_HEAT}).first

    return nil if process_detail.nil?
    
    sym = nil
    case process_detail.tanaka_flag
    when TANAKA_FLAG_0SHARP
      sym = :tanaka_0SHARP
    when TANAKA_FLAG_TP
      sym = :tanaka_TP
    end

    return nil if sym.nil?
    
    return I18n.t(sym, :scope => [:activerecord, :attributes, :process_detail])
  end

  def environment
    #工程詳細の表面処理のデータ検索
    process_detail = process_details.includes(:process_type).where(process_details: {hexavalent_flag: FLAG_ON}).where(process_types: {processor_flag: PROCESSOR_FLAG_SURFACE}).first

    sym = :not_hexavalent
    sym = :hexavalent unless process_detail.nil?

    return I18n.t(sym, :scope => [:activerecord, :attributes, :process_detail])
  end

  def material
    materials.first
  end
  
  def washer1
    return get_washer(1)
  end

  def washer2
    return get_washer(2)
  end

  def set_parts(parts)
    item_material_seq = item_material_seqs.first
    item_material_seq ||= ItemMaterialSeq.new
    if parts.material_id.blank?
      item_material_seqs.delete(item_material_seq)
    else
      material = Material.find(parts.material_id)
      item_material_seq.material = material
      item_material_seq.seq = 1
      item_material_seqs << item_material_seq
    end

    item_washer_seq1 = item_washer_seqs.where(seq: 1).first
    item_washer_seq1 ||= ItemWasherSeq.new
    if parts.washer_id1.blank?
      item_washer_seqs.delete(item_washer_seq1)
    else
      washer = Washer.find(parts.washer_id1)
      item_washer_seq1.washer = washer
      item_washer_seq1.seq = 1
      item_washer_seqs << item_washer_seq1
    end

    item_washer_seq2 = item_washer_seqs.find(seq: 2).first
    item_washer_seq2 ||= ItemWasherSeq.new
    if parts.washer_id2.blank?
      item_washer_seqs.delete(item_washer_seq2)
    else
      washer = Washer.find(parts.washer_id2)
      item_washer_seq2.washer = washer
      item_washer_seq2.seq = 2
      item_washer_seqs << item_washer_seq2
    end
  end

  def expense
    return if weight.blank?
    return if material.nil?
    
    material_unit_price = Material.find_material_price_by_target_date(material.id, Date.today)
    
    return weight * material_unit_price
  end

  def disp_text
    customer_code.to_s + ' - ' + code.to_s
  end
  
  def valid_relations?
    return false if process_expense.nil?
    return false if (header_right_check_sheet.nil? && header_left_check_sheet.nil? && rolling_right_check_sheet.nil? && rolling_left_check_sheet.nil?)
    return false if process_details.empty?
    return false if materials.empty?
    
    return true
  end

  # private instance method ====================================================
  def customer_exist?
    unless (customer_code.blank?)
      customer = Customer.find_by_code(customer_code)
      if customer.nil?
        errors.add(:customer_code, :not_exist)
      end
    end
  end

  def get_washer(seq)
    item_washer_seq = item_washer_seqs.where(seq: seq).first
    washer = item_washer_seq.washer unless item_washer_seq.nil?
    return washer
  end

  def self.available(cond_customer_code, cond_code, cond_drawing_no, cond_name)
    conds = "1 = 1"
    conds_param = []

    if cond_customer_code.present?
      conds += " AND customer_code = ?"
      conds_param << cond_customer_code
    end
    if cond_code.present?
      conds += " AND code = ?"
      conds_param << cond_code
    end
    if cond_drawing_no.present?
      conds += " AND drawing_no LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_drawing_no.strip)]
    end
    if cond_name.present?
      conds += " AND name LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_name.strip)]
    end

    self.where([conds] + conds_param)
  end
end
