class InternalProcessor < Processor
  
  # public class method ========================================================
  def self.calc_process_expense?(trader_id)
    return false if trader_id.blank?
    
    trader = self.find_by_id(trader_id)
    return false if trader.nil?
    
    return !trader.addition_attr3.blank?
  end

  def self.available(cond_id, cond_name, cond_address)
    conds = "1 = 1"
    conds_param = []

    if cond_id.present?
      conds += " AND id = ?"
      conds_param << cond_id
    end
    if cond_name.present?
      conds += " AND name LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_name.strip)]
    end
    if cond_address.present?
      conds += " AND address LIKE ?"
      conds_param << "%%%s%%" % [sanitize_sql_like(cond_address.strip)]
    end

    where([conds] + conds_param)
  end

  # accessor ===================================================================

  # public instance method =====================================================

  private

  # private instance method ====================================================
  
end
