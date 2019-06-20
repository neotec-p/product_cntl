class Customer < ActiveRecord::Base
  has_many :items
  
  validates_presence_of     :code
  validates_length_of       :code, :is => 3
  validates_alphanumeric_of :code
  validates_uniqueness_of   :code
  
  validates_presence_of     :name
  validates_length_of       :name,  :maximum => 50
  
  validates_length_of       :note,  :maximum => 255

  # public class method ========================================================
  def self.available(cond_code, cond_name)
    conds = "1 = 1"
    conds_param = []

    if cond_code.present?
      conds += " AND code = ?"
      conds_param << cond_code
    end
    if cond_name.present?
      conds += " AND name LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_name.strip)]
    end
    
    self.where([conds] + conds_param)
  end

  # accessor ===================================================================

  # public instance method =====================================================
  def disp_text
    code + " : " + name
  end

  private

  # private instance method ====================================================
  
end
