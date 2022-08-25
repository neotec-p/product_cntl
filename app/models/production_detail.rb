class ProductionDetail < ActiveRecord::Base
  belongs_to :production
  belongs_to :process_detail
  has_one :process_order
  belongs_to :model, optional: true

  validates_numericality_of :model_id, :allow_blank => true

  validates_numericality_of :result_amount_production, :allow_blank => true
  validates_numericality_of :result_amount_history, :allow_blank => true

  validates_numericality_of :defectiveness_amount, :allow_blank => true

  validates_date_compare_of :plan_end_ymd, :type => :future_than_or_equal_to, :compare_to => 'plan_start_ymd'
  validates_date_compare_of :result_end_ymd, :type => :future_than_or_equal_to, :compare_to => 'result_start_ymd'
  
  before_validation :set_result_amount
  
  # public class method ========================================================
  # none

  # accessor ===================================================================
  attr_accessor :no_in_list
  attr_accessor :select_print

  # public instance method =====================================================
  def create_model_options
    options = {}

    item = production.item
    
    case process_detail.process_type.plan_process_flag
    when PLAN_PROCESS_FLAG_HD
      cond = []
      cond << item.hd_model_name1 unless item.hd_model_name1.nil?
      cond << item.hd_model_name2 unless item.hd_model_name2.nil?
      cond << item.hd_model_name3 unless item.hd_model_name3.nil?
      options = create_model_options_core(cond)
    when PLAN_PROCESS_FLAG_HD_ADDITION
      cond = []
      cond << item.hd_addition_model_name unless item.hd_addition_model_name.nil?
      options = create_model_options_core(cond)
    when PLAN_PROCESS_FLAG_RO1
      cond = []
      cond << item.ro1_model_name1 unless item.ro1_model_name1.nil?
      cond << item.ro1_model_name2 unless item.ro1_model_name2.nil?
      cond << item.ro1_model_name3 unless item.ro1_model_name3.nil?
      options = create_model_options_core(cond)
    when PLAN_PROCESS_FLAG_RO1_ADDITION
      cond = []
      cond << item.ro1_addition_model_name unless item.ro1_addition_model_name.nil?
      options = create_model_options_core(cond)
    when PLAN_PROCESS_FLAG_RO2
      cond = []
      cond << item.ro2_model_name1 unless item.ro2_model_name1.nil?
      cond << item.ro2_model_name2 unless item.ro2_model_name2.nil?
      cond << item.ro2_model_name3 unless item.ro2_model_name3.nil?
      options = create_model_options_core(cond)
    when PLAN_PROCESS_FLAG_RO2_ADDITION
      cond = []
      cond << item.ro2_addition_model_name unless item.ro2_addition_model_name.nil?
      options = create_model_options_core(cond)
    else
    # do nothing
    end

    return options
  end

  def process_order_type
    controller = nil
    case process_detail.process_type.processor_flag
    when PROCESSOR_FLAG_HEAT
      controller = :heat_process_orders
    when PROCESSOR_FLAG_SURFACE
      controller = :surface_process_orders
    when PROCESSOR_FLAG_ADDITION
      controller = :addition_process_orders
    else
    #do nothing
    end

    return controller
  end

  def process_type
    process_type = ProcessType.new
    process_type = process_detail.process_type unless process_detail.process_type.nil?
    
    return process_type
  end

  def current_status_or_process_name
    return production.status.name unless production.status.id == STATUS_ID_NORMAL
    
    return process_type.name
  end

  def curretn_status_or_end_date
    return production.status.name unless production.status.id == STATUS_ID_NORMAL
    
    end_ymd = plan_end_ymd
    end_ymd = result_end_ymd unless result_end_ymd.nil?
    
    return "" if end_ymd.nil?
    
    return I18n.l end_ymd
  end

  def result_amount_history=(val)
    return if self.result_amount_production.blank?
    self[:result_amount_history] = self.result_amount_production
  end

  def process_expense
    item = production.item
    process_expense = item.process_expense

    expense = 0
    case process_type.plan_process_flag
    when PLAN_PROCESS_FLAG_HD
      expense = process_expense.hd unless process_expense.hd.blank?
      expense += process_expense.barrel unless process_expense.barrel.blank?
    when PLAN_PROCESS_FLAG_HD_ADDITION
      expense = process_expense.hd_addition unless process_expense.hd_addition.blank?
    when PLAN_PROCESS_FLAG_RO1
      expense = process_expense.ro1 unless process_expense.ro1.blank?
    when PLAN_PROCESS_FLAG_RO1_ADDITION
      expense = process_expense.ro1_addition unless process_expense.ro1_addition.blank?
    when PLAN_PROCESS_FLAG_RO2
      expense = process_expense.ro2 unless process_expense.ro2.blank?
    when PLAN_PROCESS_FLAG_RO2_ADDITION
      expense = process_expense.ro2_addition unless process_expense.ro2_addition.blank?
    else
      #do nothing
    end
    
    return expense
  end
  
  def calc_sum_process_expense
    item = production.item
    process_expense = item.process_expense
    category = process_type.expense_sum_category
    
    sum_expense = BigDecimal("0")
    
    return sum_expense if category.blank?
    
    if category >= EXPENSE_SUM_CATEGORY_HD
      sum_expense += process_expense.hd
    end
    if category >= EXPENSE_SUM_CATEGORY_BARREL
      sum_expense += process_expense.barrel
    end
    if category >= EXPENSE_SUM_CATEGORY_HD_ADDITION
      sum_expense += process_expense.hd_addition || 0
    end
    if category >= EXPENSE_SUM_CATEGORY_RO1
      sum_expense += process_expense.ro1
    end
    if category >= EXPENSE_SUM_CATEGORY_RO1_ADDITION
      sum_expense += process_expense.ro1_addition || 0
    end
    if category >= EXPENSE_SUM_CATEGORY_RO2
      sum_expense += process_expense.ro2
    end
    if category >= EXPENSE_SUM_CATEGORY_RO2_ADDITION
      sum_expense += process_expense.ro2_addition || 0
    end
    if category >= EXPENSE_SUM_CATEGORY_HEAT
      sum_expense += process_expense.heat
    end
    if category >= EXPENSE_SUM_CATEGORY_HEAT_ADDITION
      sum_expense += process_expense.heat_addition || 0
    end
    if category >= EXPENSE_SUM_CATEGORY_SURFACE
      sum_expense += process_expense.surface
    end
    if category >= EXPENSE_SUM_CATEGORY_SURFACE_ADDITION
      sum_expense += process_expense.surface_addition || 0
    end
    
    return sum_expense
  end

  # 生産高の算出
  def calc_sum_process_expense_yeild
    
    item = production.item
    process_expense = item.process_expense
    plan_process_flag = process_type.plan_process_flag
    
    expense = BigDecimal("0")
    
    return expense if plan_process_flag.blank?

    if plan_process_flag == PLAN_PROCESS_FLAG_HD
      expense = (process_expense.hd + process_expense.barrel)
    elsif plan_process_flag == PLAN_PROCESS_FLAG_HD_ADDITION
      expense = process_expense.hd_addition if InternalProcessor.calc_process_expense?(process_detail.trader_id)
    elsif plan_process_flag == PLAN_PROCESS_FLAG_RO1
      expense = process_expense.ro1
    elsif plan_process_flag == PLAN_PROCESS_FLAG_RO1_ADDITION
      expense = (process_expense.ro1_addition || 0) if InternalProcessor.calc_process_expense?(process_detail.trader_id)
    elsif plan_process_flag == PLAN_PROCESS_FLAG_RO2
      expense = process_expense.ro2
    elsif plan_process_flag == PLAN_PROCESS_FLAG_RO2_ADDITION
      expense = (process_expense.ro2_addition || 0) if InternalProcessor.calc_process_expense?(process_detail.trader_id)
    end
    
    return expense || 0
  end
  
  # 他社工程か？
  def out_addition_process?
    #外注工程以外はfalse
    return false unless ProcessType.processor_flags.include?(process_type.processor_flag)
    
    #追加工以外はtrue
    return true unless process_type.processor_flag == PROCESSOR_FLAG_ADDITION
    
    #工程詳細.業者IDが自社内工程に含まれていればfalse
    trader = InternalProcessor.find_by_id(process_detail.trader_id)
    
    return trader.nil?
  end

  def self.filter_with_vote_no(cond_vote_no)
    self.includes([[:process_detail => :process_type], [:production => :order]])
        .where(productions: { vote_no: cond_vote_no })
        .where.not(production_details: { result_amount_production: nil })
        .where(productions: { parts_fix_flag: FLAG_ON })
        .where(Production.where(vote_no: cond_vote_no).where(summation_id: nil).exists)
        .order("orders.delivery_ymd asc, productions.vote_no asc, process_types.seq asc")
  end

  def self.filter_by_productions(cond_process_type_id, cond_status_id, cond_item_customer_code, cond_item_code, cond_sort, cond_order, cond_unprinted)
    conds = "1 = 1"
    params = []

    if cond_process_type_id.present?
      conds += " and process_details.process_type_id = ?"
      params << cond_process_type_id
    end
    if cond_status_id.present?
      conds += " and productions.status_id = ?"
      params << cond_status_id
    end
    if cond_item_customer_code.present?
      conds += " and productions.customer_code = ?"
      params << cond_item_customer_code
    end
    if cond_item_code.present?
      conds += " and productions.code = ?"
      params << cond_item_code
    end
    conds += " and production_details.result_amount_production IS NOT NULL"
    conds += " and productions.parts_fix_flag = ?"
    params << FLAG_ON
    conds += " and productions.summation_id IS NULL"

    if cond_unprinted
      conds += " and productions_reports.report_id IS NULL"
    end

    case cond_sort
    when "name"
      order = "productions.status_id asc," + " process_details.process_type_id " + cond_order + "," + " models.name asc, models.code asc, production_details.plan_start_ymd is null, production_details.plan_start_ymd asc"
    when "model_name"
      order = "productions.status_id asc," + " models.name is null, models.name " + cond_order + "," + " process_details.process_type_id asc, production_details.plan_start_ymd is null, production_details.plan_start_ymd asc , models.code asc" if cond_sort == "model_name"
    when "plan_start_ymd"
      order = "productions.status_id asc," + " production_details.plan_start_ymd is null, production_details.plan_start_ymd " + cond_order + "," + " process_details.process_type_id asc, models.name asc, models.code asc"
    else
      order = " productions.status_id asc, process_details.process_type_id asc, models.name is null, models.name asc, models.code asc, production_details.plan_start_ymd is null, production_details.plan_start_ymd asc"
    end

    self.includes([[:process_detail => [:process_type]], :model, [:production => [:order, :reports]]]).where([conds] + params).order(order + ", process_details.id asc")
  end

  private

  # private instance method ====================================================
  def create_model_options_core(cond)
    options = []
    
    models = Model.where(["name in (?)", cond]).order("name asc, code asc")
    models.each { |model|
      vals = [model.name + ":" + model.code, model.id]
      options << vals
    }

    return options
  end

  def set_result_amount
    self[:result_amount_history] = self.result_amount_production unless self.result_amount_production.blank?
  end

end
