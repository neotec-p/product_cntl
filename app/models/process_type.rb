class ProcessType < ActiveRecord::Base
  has_many :process_details
  
  has_and_belongs_to_many :models

  # public class method ========================================================
  def self.seq_asc
    "process_types.seq asc"
  end
  
  def self.find_plan_process
    self.where(["plan_process_flag in (?)", self.plan_process_flags]).order("seq asc")
  end
  
  def self.plan_process_flags
    return [PLAN_PROCESS_FLAG_HD, PLAN_PROCESS_FLAG_HD_ADDITION, PLAN_PROCESS_FLAG_RO1, PLAN_PROCESS_FLAG_RO1_ADDITION, PLAN_PROCESS_FLAG_RO2, PLAN_PROCESS_FLAG_RO2_ADDITION]
  end

  def self.plan_process_flags_hd
    return [PLAN_PROCESS_FLAG_HD, PLAN_PROCESS_FLAG_HD_ADDITION]
  end

  def self.plan_process_flags_ro
    return [PLAN_PROCESS_FLAG_RO1, PLAN_PROCESS_FLAG_RO1_ADDITION, PLAN_PROCESS_FLAG_RO2, PLAN_PROCESS_FLAG_RO2_ADDITION]
  end

  def self.last_inner_process_type
    return self.where("plan_process_flag = ?", PLAN_PROCESS_FLAG_RO2_ADDITION).first
  end

  def self.processor_flags
    return [PROCESSOR_FLAG_HEAT, PROCESSOR_FLAG_SURFACE, PROCESSOR_FLAG_ADDITION]
  end
  
  def self.plan_process_flags_by_category(category)
    cond_process_flags = []
    case category
    when PROCESS_CATEGORY_HD
      cond_process_flags = self.plan_process_flags_hd
    when PROCESS_CATEGORY_RO
      cond_process_flags = self.plan_process_flags_ro
    end
    return cond_process_flags
  end
  
end
