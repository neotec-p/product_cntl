class Defective < ActiveRecord::Base
  belongs_to :item
  belongs_to :defective_process_type
  belongs_to :model

  has_many :defective_material_stock_seqs, :dependent => :destroy
  accepts_nested_attributes_for :defective_material_stock_seqs, :reject_if => proc { |a| a.new_record? }
  has_many :material_stocks, :through => :defective_material_stock_seqs

  has_many :defective_washer_stock_seqs, :dependent => :destroy
  accepts_nested_attributes_for :defective_washer_stock_seqs, :reject_if => proc { |a| a.new_record? }
  has_many :washer_stocks, :through => :defective_washer_stock_seqs

  validates_presence_of     :outbreak_ymd

  validates_presence_of     :defective_process_type_id
  validates_numericality_of :defective_process_type_id, :allow_blank => true

  validates_presence_of     :model_id
  
  validates_presence_of     :item_customer_code
  validates_length_of     :item_customer_code,  :maximum => 3  , :allow_blank => true
  validates_presence_of     :item_code
  validates_length_of     :item_code,  :maximum => 4 , :allow_blank => true

  validates_presence_of     :amount
  validates_numericality_of :amount, :allow_blank => true
  validates_presence_of     :weight
  validates_numericality_of :weight, :allow_blank => true

  validates_presence_of     :material_stock_id1
  
  validates_numericality_of :material_weight1, :allow_blank => true
  validates_presence_of :material_weight1, {:unless => Proc.new {|x| x.material_stock_id1.blank? }}

  validates_numericality_of :washer_quantity1, :allow_blank => true
  validates_presence_of :washer_quantity1, {:unless => Proc.new {|x| x.washer_stock_id1.blank? }}

  validates_numericality_of :washer_quantity2, :allow_blank => true
  validates_presence_of :washer_quantity2, {:unless => Proc.new {|x| x.washer_stock_id2.blank? }}

  validate :item_exists?
  validate :material_stock_exists?
  validate :washer_stock_exists?

  before_save :relate_models

  # public class method ========================================================

  # accessor ===================================================================
  attr_accessor :material_stock_id1
  attr_accessor :material_weight1
  attr_accessor :washer_stock_id1
  attr_accessor :washer_quantity1
  attr_accessor :washer_stock_id2
  attr_accessor :washer_quantity2

  attr_accessor :expense
  attr_accessor :process_expense
  attr_accessor :material_expense
  attr_accessor :hd
  attr_accessor :barrel
  attr_accessor :hd_addition
  attr_accessor :ro1
  attr_accessor :ro1_addition
  attr_accessor :ro2
  attr_accessor :ro2_addition

  # public instance method =====================================================
  def material_stock_id1_before_type_cast
    return self.material_stock_id1
  end
  def material_weight1_before_type_cast
    return self.material_weight1
  end
  def washer_stock_id1_before_type_cast
    return self.washer_stock_id1
  end
  def washer_quantity1_before_type_cast
    return self.washer_quantity1
  end
  def washer_stock_id2_before_type_cast
    return self.washer_stock_id2
  end
  def washer_quantity2_before_type_cast
    return self.washer_quantity2
  end

  def calc_amount!
    process_expense = ProcessExpense.find_by_target_date(item.id, outbreak_ymd)
    
    return if process_expense.nil?
    
    @process_expense = 0
    @material_expense = 0
    @hd = 0
    @barrel = 0
    @hd_addition = 0
    @ro1 = 0
    @ro1_addition = 0
    @ro2 = 0
    @ro2_addition = 0
    
    #仕掛＠
    if defective_process_type_id >= DEFECTIVE_PROCESS_TYPE_HD
      @hd = process_expense.hd
      @barrel = process_expense.barrel
    end
    if defective_process_type_id >= DEFECTIVE_PROCESS_TYPE_HD_PLUS
      @hd_addition = process_expense.hd_addition
    end
    if defective_process_type_id >= DEFECTIVE_PROCESS_TYPE_RO1
      @ro1 = process_expense.ro1
    end
    if defective_process_type_id >= DEFECTIVE_PROCESS_TYPE_RO1_PLUS
      @ro1_addition = process_expense.ro1_addition
    end
    if defective_process_type_id >= DEFECTIVE_PROCESS_TYPE_RO2
      @ro2 = process_expense.ro2
    end
    if defective_process_type_id >= DEFECTIVE_PROCESS_TYPE_RO2_PLUS
      @ro2_addition = process_expense.ro2_addition
    end

p @barrel
p @hd
p @hd_addition
p @ro1
p @ro1_addition
p @ro2
p @ro2_addition
    
    @process_expense = @hd + @barrel + (@hd_addition || 0) + @ro1 + (@ro1_addition || 0)+ @ro2 + (@ro2_addition || 0)
    
    #金額 = 仕掛＠ * 不良.数量（本）
    @expense = @process_expense * amount

    #材料費 = （発生年月日時に有効だった単価）材料.単価（円） * 不良.材料重量（ｋｇ）
    defective_material_stock_seq1 = defective_material_stock_seqs.where(:seq => 1).first
    unless defective_material_stock_seq1.nil?
      material_stock = defective_material_stock_seq1.material_stock
      material = material_stock.material
      
      material_unit_price = Material.find_material_price_by_target_date(material.id, outbreak_ymd)
      @material_expense += material_unit_price * defective_material_stock_seq1.weight
    end
    #座金１費 = （発生年月日時に有効だった単価）座金.単価（円） * 不良.座金１数量（ｐｃｓ）
    defective_washer_stock_seq1 = defective_washer_stock_seqs.where(:seq => 1).first
    unless defective_washer_stock_seq1.nil?
      washer_stock = defective_washer_stock_seq1.washer_stock
      washer = washer_stock.washer
      
      washer_unit_price = Washer.find_washer_price_by_target_date(washer.id, outbreak_ymd)
      @material_expense += washer_unit_price * defective_washer_stock_seq1.quantity
    end
    #座金２費 = （発生年月日時に有効だった単価）座金.単価（円） * 不良.座金２数量（ｐｃｓ）
    defective_washer_stock_seq2 = defective_washer_stock_seqs.where(:seq => 2).first
    unless defective_washer_stock_seq2.nil?
      washer_stock = defective_washer_stock_seq2.washer_stock
      washer = washer_stock.washer
      
      washer_unit_price = Washer.find_washer_price_by_target_date(washer.id, outbreak_ymd)
      @material_expense += washer_unit_price * defective_washer_stock_seq2.quantity
    end
  end

  private
  # private instance method ====================================================
  def item_exists?
    unless (item_customer_code.blank? || item_code.blank?)
      item = Item.findByItemCode(item_customer_code, item_code)
      if item.nil?
        errors.add(:item_customer_code, :not_exist)
        errors.add(:item_code, :not_exist)
      end
    end
  end

  def material_stock_exists?
    unless material_stock_id1.blank?
      unless MaterialStock.exists?(material_stock_id1)
        errors.add(:material_stock_id1, :not_exist)
      end
    end
  end

  def washer_stock_exists?
    unless washer_stock_id1.blank?
      unless WasherStock.exists?(washer_stock_id1)
        errors.add(:washer_stock_id1, :not_exist)
      end
    end
    unless washer_stock_id2.blank?
      unless WasherStock.exists?(washer_stock_id2)
        errors.add(:washer_stock_id2, :not_exist)
      end
    end
  end

  def relate_models
    self.item = Item.findByItemCode(item_customer_code, item_code)
    
    defective_material_stock_seq1 = defective_material_stock_seqs.where(:seq => 1).first
    defective_material_stock_seq1 ||= DefectiveMaterialStockSeq.new

    if material_stock_id1.blank?
      defective_material_stock_seqs.delete(defective_material_stock_seq1)
    else
      material_stock = MaterialStock.find(material_stock_id1)
      defective_material_stock_seq1.material_stock = material_stock
      defective_material_stock_seq1.defective = self
      defective_material_stock_seq1.weight = self.material_weight1
      defective_material_stock_seq1.seq = 1

      defective_material_stock_seqs << defective_material_stock_seq1
    end

    defective_washer_stock_seq1 = defective_washer_stock_seqs.where(:seq => 1).first
    defective_washer_stock_seq1 ||= DefectiveWasherStockSeq.new

    if washer_stock_id1.blank?
      defective_washer_stock_seqs.delete(defective_washer_stock_seq1)
    else
      washer_stock = WasherStock.find(washer_stock_id1)
      defective_washer_stock_seq1.washer_stock = washer_stock
      defective_washer_stock_seq1.defective = self
      defective_washer_stock_seq1.quantity = self.washer_quantity1
      defective_washer_stock_seq1.seq = 1

      defective_washer_stock_seqs << defective_washer_stock_seq1
    end
    
    defective_washer_stock_seq2 = defective_washer_stock_seqs.where(:seq => 2).first
    defective_washer_stock_seq2 ||= DefectiveWasherStockSeq.new

    if washer_stock_id2.blank?
      defective_washer_stock_seqs.delete(defective_washer_stock_seq2)
    else
      washer_stock = WasherStock.find(washer_stock_id2)
      defective_washer_stock_seq2.washer_stock = washer_stock
      defective_washer_stock_seq2.defective = self
      defective_washer_stock_seq2.quantity = self.washer_quantity2
      defective_washer_stock_seq2.seq = 2

      defective_washer_stock_seqs << defective_washer_stock_seq2
    end
  end

  public
  def self.available(cond_date_from, cond_date_to, cond_item_customer_code, cond_item_code, cond_contents)
    conds = "1 = 1"
    conds_param = []

    if cond_date_from.present?
      conds += " AND ? <= outbreak_ymd"
      conds_param << cond_date_from
    end
    if cond_date_to.present?
      conds += " AND outbreak_ymd < ?"
      conds_param << (cond_date_to + 1.days)
    end
    if cond_item_customer_code.present?
      conds += " AND item_customer_code = ?"
      conds_param << cond_item_customer_code
    end
    if cond_item_code.present?
      conds += " AND item_code = ?"
      conds_param << cond_item_code
    end
    if cond_contents.present?
      conds += " AND contents like ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_contents.strip)]
    end

    self.where([conds] + conds_param)
  end
end
