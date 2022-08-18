class Model < ActiveRecord::Base
  has_and_belongs_to_many :process_types
  has_many :defectives

  validates_presence_of     :code
  validates_length_of     :code,  :maximum => 3
  validates_hankaku_of      :code
  validates_uniqueness_of   :code, :scope => [:code, :name]

  validates_presence_of     :name
  validates_uniqueness_of   :name, :scope => [:code, :name]

  # public class method ========================================================
  def self.find_by_plan_process_flag(plan_process_flag)
    self.includes(:process_types).where(process_types: {plan_process_flag: plan_process_flag}).group("models.name").order("models.name")
  end

  def self.available(cond_code, cond_name)
    conds = "1 = 1"
    conds_param = []

    if cond_code.present?
      conds += " AND code = ?"
      conds_param << code_code
    end
    if cond_name.present?
      conds += " AND name = ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_name.strip)]
    end
      
    self.where([conds] + conds_param)
  end

  # accessor ===================================================================

  # public instance method =====================================================
  def disp_text
    name + ":" + code
  end

  private

  # private instance method ====================================================
  

end
