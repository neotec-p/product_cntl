class ProcessDetail < ActiveRecord::Base
  belongs_to :item
  belongs_to :process_type, optional: true
  belongs_to :trader, optional: true
  
  has_many :production_details

  validates_presence_of     :item_id
  validates_numericality_of :item_id

  validates_presence_of     :process_type_id
  validates_numericality_of :process_type_id

  before_save :prepare_name

  # public class method ========================================================

  # accessor ===================================================================

  # public instance method =====================================================
  def disp_cond
    disp = []
    disp << name unless name.blank?
    disp << condition unless condition.blank?
    return disp.join(" ")
  end

  private

  # private instance method ====================================================
  def prepare_name
    if process_type.protected_flag == PROTECTED_FLAG_START #計画工程
      if name.blank?
        tmp = ProcessType.find_by_protected_flag(PROTECTED_FLAG_START)
        self.name = tmp.name
      end
    end
    
    if process_type.protected_flag == PROTECTED_FLAG_FINISH #倉入工程
      if name.blank?
        tmp = ProcessType.find_by_protected_flag(PROTECTED_FLAG_FINISH)
        self.name = tmp.name
      end
    end
    
    self.model = ""
    unless trader_id.blank?
      self.model = trader.name unless trader.nil?
    end
  end
  
end
