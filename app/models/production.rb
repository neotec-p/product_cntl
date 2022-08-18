class Production < ActiveRecord::Base
  belongs_to :order
  belongs_to :item
  belongs_to :status
  belongs_to :summation, optional: true

  has_one :lot, :dependent => :destroy
  accepts_nested_attributes_for :lot, :reject_if => :new_record?

  has_many :production_details, :dependent => :destroy
  accepts_nested_attributes_for :production_details, :reject_if => :new_record?

  has_many :material_production_seqs, :dependent => :destroy
  accepts_nested_attributes_for :material_production_seqs, :reject_if => proc { |a| a.new_record? }
  has_many :materials, :through => :material_production_seqs

  has_many :washer_production_seqs, :dependent => :destroy
  accepts_nested_attributes_for :washer_production_seqs, :reject_if => proc { |a| a.new_record? }
  has_many :washers, :through => :washer_production_seqs

  has_many :material_stock_production_seqs, :dependent => :destroy
  accepts_nested_attributes_for :material_stock_production_seqs, :reject_if => proc { |a| a.new_record? }
  has_many :material_stocks, :through => :material_stock_production_seqs

  has_many :washer_stock_production_seqs, :dependent => :destroy
  accepts_nested_attributes_for :washer_stock_production_seqs, :reject_if => proc { |a| a.new_record? }
  has_many :washer_stocks, :through => :washer_stock_production_seqs

  has_many :memos, :dependent => :destroy

  has_and_belongs_to_many :reports

  validates_presence_of     :status_id
  validates_numericality_of :status_id

  validates_presence_of     :vote_no
  validates_numericality_of :vote_no

  validates_presence_of     :branch1_no
  validates_numericality_of :branch1_no

  validates_presence_of     :branch2_no
  validates_numericality_of :branch2_no

  validates_presence_of     :customer_code
  validates_length_of     :customer_code,  :maximum => 3

  validates_presence_of     :code
  validates_length_of     :code,  :maximum => 4

  validates_numericality_of :result_amount, :allow_blank => true

  validates_numericality_of :parts_fix_flag, :allow_blank => true

  before_validation :set_result_amount

  validate :result_amount_production_any?
  validate :finishable?

  # public class method ========================================================
  def self.vote_no_asc
    "productions.vote_no asc, productions.branch1_no asc, productions.branch2_no asc"
  end

  def self.find_by_vote_no_and_branch_nos(vote_no, branch1_no, branch2_no)
    return self.where(["vote_no = ? and branch1_no = ? and branch2_no = ?", vote_no, branch1_no, branch2_no]).first
  end

  def self.find_by_vote_no(vote_no)
    return self.where(["vote_no = ?", vote_no]).order("branch1_no asc, branch2_no asc")
  end
  
  def self.find_summation_targets(lot_not_flag = false)
    conds  = " ("
    conds += " productions.summation_id IS NULL"
    conds += " and statuses.id = ?"
    conds += " and process_types.protected_flag = ?"
    conds += " and production_details.result_amount_production IS NOT NULL"
    conds += " ) OR ("
    conds += " productions.summation_id IS NULL"
    conds += " and statuses.id = ?"
    conds += " )"
    
    #ロットと紐づいているものに限定
    joins  = nil
    unless lot_not_flag
      joins  = " INNER JOIN lots"
      joins += " ON lots.production_id = productions.id"
    end

    target_productions = Production.joins(joins).includes([:status, [:production_details => [:process_detail => :process_type]]]).where([conds, STATUS_ID_NORMAL, PROTECTED_FLAG_FINISH, STATUS_ID_BAD]).references(:status)
    
    return target_productions
  end

  def self.filter_by_yeild(cond_target_ymd_start, cond_target_ymd_end, cond_process_type_id)
    conds = "1 = 1"
    params = []

    if cond_target_ymd_end.present?
      conds += " and (production_details.result_start_ymd <= ?)"
      params << cond_target_ymd_end
    end
    if cond_target_ymd_start.present?
      conds += " and (? <= production_details.result_end_ymd)"
      params << cond_target_ymd_start
    end
    conds += " and production_details.result_start_ymd IS NOT NULL"
    conds += " and production_details.result_end_ymd IS NOT NULL"
    conds += " and production_details.result_start_ymd <= production_details.result_end_ymd"
    conds += " and process_types.plan_process_flag in (?)"
    params << ProcessType.plan_process_flags
    conds += " and productions.parts_fix_flag = ?"
    params << FLAG_ON
    conds += " and productions.summation_id IS NULL"

    if cond_process_type_id.present?
      conds += " and process_details.process_type_id = ?"
      params << cond_process_type_id
    end

    self.includes(:production_details => { :process_detail => :process_type }).where([conds] + params).references([:production_details, :process_details, :process_types])
  end

  # public instance method =====================================================
  def sort_production_details!
    self.production_details.to_a.sort!{|a, b| a.process_detail.process_type.seq <=> b.process_detail.process_type.seq}
  end

  def disp_text
    #vote_no.to_s + '-' + disp_branch_no
    "%s-%s" % [vote_no, disp_branch_no]
  end

  def disp_branch_no
    #branch1_no.to_s + '-' + branch2_no.to_s
    "%s-%s" % [branch1_no, branch2_no]
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

  def material_stock
    material_stocks.first
  end

  def washer_stocks1
    return get_washer_stocks(1)
  end

  def washer_stocks2
    return get_washer_stocks(2)
  end

  def plan_weight
    val = 0
    val = item.weight * order.necessary_amount if (!item.weight.blank? && !order.necessary_amount.blank?)
    return val
  end

  def current_process_type
    process_type = nil

    tmp_details = production_details.sort{ |a,b| a.id <=> b.id }
    tmp_details.each{ |production_detail|
      unless production_detail.result_amount_production.blank?
        unless production_detail.process_detail.nil?
        process_type = production_detail.process_detail.process_type
        end
      end
    }

    raise "current process_type is null." if process_type.nil?

    return process_type
  end

  def find_by_plan_process_flag(plan_process_flag)
    production_detail = production_details.includes(:process_detail => :process_type).where(
      process_types: { process_flag: plan_process_flag }
    ).first

    return production_detail
  end

  def find_by_plan_processor_flag(processor_flag)
    production_detail = production_details.includes(:process_detail => :process_type).where(
      process_types: { processor_flag: processor_flag }
    ).first

    return production_detail
  end

  def current_status_or_process_name
    return status.name unless status.id == STATUS_ID_NORMAL

    return current_process_type.name
  end

  def create_new_lot
    new_lot = Lot.new

    tmp_lot_no = Lot.maximum(:lot_no)

    if tmp_lot_no.nil?
       tmp_lot_no = LOT_NO_INIT
    end    
    tmp_lot_no += 1

    new_lot.lot_no = tmp_lot_no
    new_lot.insert_ymd = Date.today

    return new_lot
  end

  def set_model(production_plan)
    production_details.each { |production_detail|
      case production_detail.process_type.plan_process_flag
      when PLAN_PROCESS_FLAG_HD
        production_detail.model_id = production_plan.hd_model_id
        production_detail.save!
      when PLAN_PROCESS_FLAG_HD_ADDITION
        production_detail.model_id = production_plan.hd_addition_model_id
        production_detail.save!
      when PLAN_PROCESS_FLAG_RO1
        production_detail.model_id = production_plan.ro1_model_id
        production_detail.save!
      when PLAN_PROCESS_FLAG_RO1_ADDITION
        production_detail.model_id = production_plan.ro1_addition_model_id
        production_detail.save!
      when PLAN_PROCESS_FLAG_RO2
        production_detail.model_id = production_plan.ro2_model_id
        production_detail.save!
      when PLAN_PROCESS_FLAG_RO2_ADDITION
        production_detail.model_id = production_plan.ro2_addition_model_id
        production_detail.save!
      else
      # do nothing
      end
    }
  end

  def set_plan(production_plan)
    production_details.each { |production_detail|
      case production_detail.process_type.plan_process_flag
      when PLAN_PROCESS_FLAG_HD
        if production_plan.hd_start_ymd_edit_flag
        production_detail.plan_start_ymd = production_plan.hd_start_ymd
        production_detail.save!
        end
        if production_plan.hd_end_ymd_edit_flag
        production_detail.plan_end_ymd = production_plan.hd_end_ymd
        production_detail.save!
        end
      when PLAN_PROCESS_FLAG_HD_ADDITION
        if production_plan.hd_addition_start_ymd_edit_flag
        production_detail.plan_start_ymd = production_plan.hd_addition_start_ymd
        production_detail.save!
        end
        if production_plan.hd_addition_end_ymd_edit_flag
        production_detail.plan_end_ymd = production_plan.hd_addition_end_ymd
        production_detail.save!
        end
      when PLAN_PROCESS_FLAG_RO1
        if production_plan.ro1_start_ymd_edit_flag
        production_detail.plan_start_ymd = production_plan.ro1_start_ymd
        production_detail.save!
        end
        if production_plan.ro1_end_ymd_edit_flag
        production_detail.plan_end_ymd = production_plan.ro1_end_ymd
        production_detail.save!
        end
      when PLAN_PROCESS_FLAG_RO1_ADDITION
        if production_plan.ro1_addition_start_ymd_edit_flag
        production_detail.plan_start_ymd = production_plan.ro1_addition_start_ymd
        production_detail.save!
        end
        if production_plan.ro1_addition_end_ymd_edit_flag
        production_detail.plan_end_ymd = production_plan.ro1_addition_end_ymd
        production_detail.save!
        end
      when PLAN_PROCESS_FLAG_RO2
        if production_plan.ro2_start_ymd_edit_flag
        production_detail.plan_start_ymd = production_plan.ro2_start_ymd
        production_detail.save!
        end
        if production_plan.ro2_end_ymd_edit_flag
        production_detail.plan_end_ymd = production_plan.ro2_end_ymd
        production_detail.save!
        end
      when PLAN_PROCESS_FLAG_RO2_ADDITION
        if production_plan.ro2_addition_start_ymd_edit_flag
        production_detail.plan_start_ymd = production_plan.ro2_addition_start_ymd
        production_detail.save!
        end
        if production_plan.ro2_addition_end_ymd_edit_flag
        production_detail.plan_end_ymd = production_plan.ro2_addition_end_ymd
        production_detail.save!
        end
      else
      # do nothing
      end
    }
  end

  def fix_parts(parts)
    material_production_seq = material_production_seqs.first
    material_production_seq = MaterialProductionSeq.new if material_production_seq.nil?
    if parts.material_id.blank?
      material_production_seqs.delete(material_production_seq)
    else
      material = Material.find(parts.material_id)
      material_production_seq.material = material
      material_production_seq.seq = 1
      material_production_seqs << material_production_seq
    end

    washer_production_seq1 = washer_production_seqs.where(seq: 1).first
    washer_production_seq1 = WasherProductionSeq.new if washer_production_seq1.nil?
    if parts.washer_id1.blank?
      washer_production_seqs.delete(washer_production_seq1)
    else
      washer = Washer.find(parts.washer_id1)
      washer_production_seq1.washer = washer
      washer_production_seq1.seq = 1
      washer_production_seqs << washer_production_seq1
    end

    washer_production_seq2 = washer_production_seqs.where(seq: 2).first
    washer_production_seq2 = WasherProductionSeq.new if washer_production_seq2.nil?
    if parts.washer_id2.blank?
      washer_production_seqs.delete(washer_production_seq2)
    else
      washer = Washer.find(parts.washer_id2)
      washer_production_seq2.washer = washer
      washer_production_seq2.seq = 2
      washer_production_seqs << washer_production_seq2
    end

    self.parts_fix_flag = FLAG_ON
  end

  def div_branch(production_div)
    new_production = Production.new(attributes)
    new_production.branch1_no = production_div.new_branch1_no
    new_production.branch2_no = production_div.new_branch2_no

    new_production.parts_fix_flag = FLAG_OFF

    new_production.created_at = nil
    new_production.updated_at = nil
    new_production.lock_version = 0

    production_details.each{ |production_detail|
      new_production_detail = ProductionDetail.new
      new_production_detail.process_detail = production_detail.process_detail

      if new_production_detail.process_detail.process_type.protected_flag == PROTECTED_FLAG_START
      new_production_detail.result_amount_production = 0
      end

      new_production.production_details << new_production_detail
    }

    material_production_seqs.each{ |material_production_seq|
      new_material_production_seq = MaterialProductionSeq.new()
      new_material_production_seq = MaterialProductionSeq.new(material_production_seq.attributes)
      new_material_production_seq.created_at = nil
      new_material_production_seq.updated_at = nil
      new_material_production_seq.lock_version = 0

      new_production.material_production_seqs << new_material_production_seq
    }

    washer_production_seqs.each{ |washer_production_seq|
      new_washer_production_seq = WasherProductionSeq.new
      new_washer_production_seq = WasherProductionSeq.new(washer_production_seq.attributes)
      new_washer_production_seq.created_at = nil
      new_washer_production_seq.updated_at = nil
      new_washer_production_seq.lock_version = 0

      new_production.washer_production_seqs << new_washer_production_seq
    }

    return new_production
  end

  def div_lot(lot_div)
    new_production = Production.new(attributes)
    new_production.branch1_no = lot_div.new_branch1_no
    new_production.branch2_no = lot_div.new_branch2_no
    new_production.status_id = lot_div.new_status_id

    new_production.created_at = nil
    new_production.updated_at = nil
    new_production.lock_version = 0

    self.status_id = lot_div.cur_status_id

    production_details.each{ |production_detail|
      new_production_detail = ProductionDetail.new(production_detail.attributes)
      unless production_detail.result_amount_production.blank?
      new_production_detail.result_amount_production = lot_div.new_result_amount
      production_detail.result_amount_production = lot_div.cur_result_amount
      end

      new_production_detail.created_at = nil
      new_production_detail.updated_at = nil
      new_production_detail.lock_version = 0

      new_production.production_details << new_production_detail
    }
    
    if lot_div.lot_exist_flag == FLAG_ON
      new_lot = create_new_lot
      new_lot.weight = lot_div.new_weight
      new_lot.case = lot_div.new_case
  
      new_production.lot = new_lot
  
      lot.weight = lot_div.cur_weight
      lot.case = lot_div.cur_case
    end

    material_production_seqs.each{ |material_production_seq|
      new_material_production_seq = MaterialProductionSeq.new(material_production_seq.attributes)
      new_material_production_seq.created_at = nil
      new_material_production_seq.updated_at = nil
      new_material_production_seq.lock_version = 0

      new_production.material_production_seqs << new_material_production_seq
    }

    washer_production_seqs.each{ |washer_production_seq|
      new_washer_production_seq = WasherProductionSeq.new(washer_production_seq.attributes)
      new_washer_production_seq.created_at = nil
      new_washer_production_seq.updated_at = nil
      new_washer_production_seq.lock_version = 0

      new_production.washer_production_seqs << new_washer_production_seq
    }

    material_stock_production_seqs.each{ |material_stock_production_seq|
      new_material_stock_production_seq = MaterialStockProductionSeq.new(material_stock_production_seq.attributes)
      new_material_stock_production_seq.created_at = nil
      new_material_stock_production_seq.updated_at = nil
      new_material_stock_production_seq.lock_version = 0

      new_production.material_stock_production_seqs << new_material_stock_production_seq
    }

    washer_stock_production_seqs.each{ |washer_stock_production_seq|
      new_washer_stock_production_seq = WasherStockProductionSeq.new
      new_washer_stock_production_seq = WasherStockProductionSeq.new(washer_stock_production_seq.attributes)
      new_washer_stock_production_seq.created_at = nil
      new_washer_stock_production_seq.updated_at = nil
      new_washer_stock_production_seq.lock_version = 0

      new_production.washer_stock_production_seqs << new_washer_stock_production_seq
    }

    return new_production
  end

  def edit_material(material_edit)
    material_production_seq = material_production_seqs.where(:seq => 1).first
    material_production_seq = MaterialProductionSeq.new if material_production_seq.nil?
    if material_edit.material_id.blank?
      material_production_seqs.delete(material_production_seq)
    else
      material = Material.find(material_edit.material_id)
      material_production_seq.material = material
      material_production_seq.production = @production
      material_production_seq.seq = 1

      material_production_seqs << material_production_seq
    end

    material_stock_production_seq1 = material_stock_production_seqs.where(:seq => 1).first
    material_stock_production_seq1 = MaterialStockProductionSeq.new if material_stock_production_seq1.nil?

    if material_edit.material_stock_id1.blank?
      material_stock_production_seqs.delete(material_stock_production_seq1)
    else
      material_stock = MaterialStock.find(material_edit.material_stock_id1)
      material_stock_production_seq1.material_stock = material_stock
      material_stock_production_seq1.production = @production
      material_stock_production_seq1.seq = 1

      material_stock_production_seqs << material_stock_production_seq1
    end

    material_stock_production_seq2 = material_stock_production_seqs.where(:seq => 2).first
    material_stock_production_seq2 = MaterialStockProductionSeq.new if material_stock_production_seq2.nil?

    if material_edit.material_stock_id2.blank?
      material_stock_production_seqs.delete(material_stock_production_seq2)
    else
      material_stock = MaterialStock.find(material_edit.material_stock_id2)
      material_stock_production_seq2.material_stock = material_stock
      material_stock_production_seq2.production = @production
      material_stock_production_seq2.seq = 2

      material_stock_production_seqs << material_stock_production_seq2
    end

    material_stock_production_seq3 = material_stock_production_seqs.where(:seq => 3).first
    material_stock_production_seq3 = MaterialStockProductionSeq.new if material_stock_production_seq3.nil?

    if material_edit.material_stock_id3.blank?
      material_stock_production_seqs.delete(material_stock_production_seq3)
    else
      material_stock = MaterialStock.find(material_edit.material_stock_id3)
      material_stock_production_seq3.material_stock = material_stock
      material_stock_production_seq3.production = @production
      material_stock_production_seq3.seq = 3

      material_stock_production_seqs << material_stock_production_seq3
    end
  end

  def edit_washer(washer_edit)
    washer_production_seq1 = washer_production_seqs.where(:seq => 1).first
    washer_production_seq1 = WasherProductionSeq.new if washer_production_seq1.nil?
    if washer_edit.washer_id1.blank?
      washer_production_seqs.delete(washer_production_seq1)
    else
      washer = Washer.find(washer_edit.washer_id1)
      washer_production_seq1.washer = washer
      washer_production_seq1.production = @production
      washer_production_seq1.seq = 1

      washer_production_seqs << washer_production_seq1
    end

    washer_stock_production_seq1 = washer_stock_production_seqs.where(:seq => 1).first
    washer_stock_production_seq1 = WasherStockProductionSeq.new if washer_stock_production_seq1.nil?

    if washer_edit.washer_stock_id1.blank?
      washer_stock_production_seqs.delete(washer_stock_production_seq1)
    else
      washer_stock = WasherStock.find(washer_edit.washer_stock_id1)
      washer_stock_production_seq1.washer_stock = washer_stock
      washer_stock_production_seq1.production = @production
      washer_stock_production_seq1.seq = 1

      washer_stock_production_seqs << washer_stock_production_seq1
    end
    washer_stock_production_seq2 = washer_stock_production_seqs.where(:seq => 2).first
    washer_stock_production_seq2 = WasherStockProductionSeq.new if washer_stock_production_seq2.nil?

    if washer_edit.washer_stock_id2.blank?
      washer_stock_production_seqs.delete(washer_stock_production_seq2)
    else
      washer_stock = WasherStock.find(washer_edit.washer_stock_id2)
      washer_stock_production_seq2.washer_stock = washer_stock
      washer_stock_production_seq2.production = @production
      washer_stock_production_seq2.seq = 2

      washer_stock_production_seqs << washer_stock_production_seq2
    end
    washer_stock_production_seq3 = washer_stock_production_seqs.where(:seq => 3).first
    washer_stock_production_seq3 = WasherStockProductionSeq.new if washer_stock_production_seq3.nil?

    if washer_edit.washer_stock_id3.blank?
      washer_stock_production_seqs.delete(washer_stock_production_seq3)
    else
      washer_stock = WasherStock.find(washer_edit.washer_stock_id3)
      washer_stock_production_seq3.washer_stock = washer_stock
      washer_stock_production_seq3.production = @production
      washer_stock_production_seq3.seq = 3

      washer_stock_production_seqs << washer_stock_production_seq3
    end

    washer_production_seq2 = washer_production_seqs.where(:seq => 2).first
    washer_production_seq2 = WasherProductionSeq.new if washer_production_seq2.nil?
    if washer_edit.washer_id2.blank?
      washer_production_seqs.delete(washer_production_seq2)
    else
      washer = Washer.find(washer_edit.washer_id2)
      washer_production_seq2.washer = washer
      washer_production_seq2.production = @production
      washer_production_seq2.seq = 2

      washer_production_seqs << washer_production_seq2
    end

    washer_stock_production_seq4 = washer_stock_production_seqs.where(:seq => 4).first
    washer_stock_production_seq4 = WasherStockProductionSeq.new if washer_stock_production_seq4.nil?
    if washer_edit.washer_stock_id4.blank?
      washer_stock_production_seqs.delete(washer_stock_production_seq4)
    else
      washer_stock = WasherStock.find(washer_edit.washer_stock_id4)
      washer_stock_production_seq4.washer_stock = washer_stock
      washer_stock_production_seq4.production = @production
      washer_stock_production_seq4.seq = 4

      washer_stock_production_seqs << washer_stock_production_seq4
    end

    washer_stock_production_seq5 = washer_stock_production_seqs.where(:seq => 5).first
    washer_stock_production_seq5 = WasherStockProductionSeq.new if washer_stock_production_seq5.nil?
    if washer_edit.washer_stock_id5.blank?
      washer_stock_production_seqs.delete(washer_stock_production_seq5)
    else
      washer_stock = WasherStock.find(washer_edit.washer_stock_id5)
      washer_stock_production_seq5.washer_stock = washer_stock
      washer_stock_production_seq5.production = @production
      washer_stock_production_seq5.seq = 5

      washer_stock_production_seqs << washer_stock_production_seq5
    end

    washer_stock_production_seq6 = washer_stock_production_seqs.where(:seq => 6).first
    washer_stock_production_seq6 = WasherStockProductionSeq.new if washer_stock_production_seq6.nil?
    if washer_edit.washer_stock_id6.blank?
      washer_stock_production_seqs.delete(washer_stock_production_seq6)
    else
      washer_stock = WasherStock.find(washer_edit.washer_stock_id6)
      washer_stock_production_seq6.washer_stock = washer_stock
      washer_stock_production_seq6.production = @production
      washer_stock_production_seq6.seq = 6

      washer_stock_production_seqs << washer_stock_production_seq6
    end
  end

  def finish_plan_date
    finish_detail = get_finish_detail
    
    finish_date = finish_detail.plan_end_ymd unless finish_detail.nil?
    
    return finish_date
  end

  # private instance method ====================================================
  def set_result_amount
    amount = 0
    production_details.each{ |production_detail|
      amount += production_detail.result_amount_production.to_i
    }
    self[:result_amount] = amount
  end

  def get_washer(seq)
    washer_production_seq = washer_production_seqs.where(seq: seq).first
    washer = washer_production_seq.washer unless washer_production_seq.nil?
    return washer
  end

  def get_washer_stocks(seq)
    seqs = [1,2,3]
    seqs = [4,5,6] if seq == 2
    
    tmp_washer_stocks = washer_stocks.where(["washer_stock_production_seqs.seq in (?)", seqs]).order("washer_stock_production_seqs.seq")
    
    return tmp_washer_stocks
  end
  
  def get_finish_detail
    production_details.includes(:process_detail => :process_type).where(process_types: { protected_flag: PROTECTED_FLAG_FINISH}).first
  end
  
  def result_amount_production_any?
    return true if self.new_record?
    production_details.each{ |production_detail|
p production_detail
      return unless production_detail.result_amount_production.nil?
    }
    errors[:base] << I18n.t("activerecord.attributes.production.result_amount_production_val") + I18n.t(:required_any, :scope => [:activerecord, :errors, :messages])
  end

  def finishable?
    production_details.each{ |production_detail|
      if production_detail.process_type.protected_flag == PROTECTED_FLAG_FINISH
        return if production_detail.result_amount_production.nil?
      end
    }
    
    #-- 支給品以外で材料在庫と紐づいていないとNG
    # 正常データだけが対象（不良は除外）
    if status.id == STATUS_ID_NORMAL
      # 材料在庫と紐づいてない
      if (!material.nil? && material.provide_flag == FLAG_OFF)
        if material_stock.nil?
          target_type = I18n.t(:material, :scope => [:activerecord, :attributes, :commons])
          errors[:base] << I18n.t(:error_valid_productions_not_rel_stocks, :material_type => target_type)
        end
      end
      
      # 座金１
      if (!washer1.nil? && washer1.provide_flag == FLAG_OFF)
        if washer_stocks1.empty?
          target_type = I18n.t(:washer_id1, :scope => [:activerecord, :attributes, :washer_edit])
          errors[:base] << I18n.t(:error_valid_productions_not_rel_stocks, :material_type => target_type)
        end
      end
      # 座金２
      if (!washer2.nil? && washer2.provide_flag == FLAG_OFF)
        if washer_stocks2.empty?
          target_type = I18n.t(:washer_id2, :scope => [:activerecord, :attributes, :washer_edit])
          errors[:base] << I18n.t(:error_valid_productions_not_rel_stocks, :material_type => target_type)
        end
      end
    end
    
  end

end
